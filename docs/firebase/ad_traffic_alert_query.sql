-- Replace `PROJECT.analytics_DATASET` with the linked GA4 BigQuery dataset.
-- Schedule once daily after the previous day's export is complete.
CREATE OR REPLACE TABLE `PROJECT.analytics_DATASET.ad_traffic_alerts` AS
WITH events AS (
  SELECT
    PARSE_DATE('%Y%m%d', event_date) AS event_day,
    event_name,
    COALESCE(geo.country, '(unknown)') AS country,
    COALESCE(app_info.version, '(unknown)') AS app_version,
    COALESCE(traffic_source.source, '(direct)') AS acquisition_source,
    COALESCE(traffic_source.medium, '(none)') AS acquisition_medium,
    COALESCE((
      SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'ad_format'
    ), '(unknown)') AS ad_format
  FROM `PROJECT.analytics_DATASET.events_*`
  WHERE _TABLE_SUFFIX BETWEEN FORMAT_DATE('%Y%m%d', DATE_SUB(CURRENT_DATE(), INTERVAL 8 DAY))
    AND FORMAT_DATE('%Y%m%d', DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY))
    AND event_name IN ('ad_impression', 'ad_loaded', 'ad_load_failed', 'ad_show_failed')
), daily AS (
  SELECT
    event_day, country, app_version, acquisition_source, acquisition_medium,
    ad_format,
    COUNTIF(event_name = 'ad_impression') AS impressions,
    COUNTIF(event_name = 'ad_loaded') AS loads,
    COUNTIF(event_name IN ('ad_load_failed', 'ad_show_failed')) AS failures
  FROM events
  GROUP BY ALL
), scored AS (
  SELECT
    *,
    AVG(IF(event_day < DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY), impressions, NULL))
      OVER (PARTITION BY country, app_version, acquisition_source, acquisition_medium, ad_format)
      AS baseline_impressions,
    SAFE_DIVIDE(failures, loads + failures) AS failure_rate
  FROM daily
)
SELECT
  CURRENT_TIMESTAMP() AS detected_at,
  country, app_version, acquisition_source, acquisition_medium, ad_format,
  impressions, loads, failures, failure_rate, baseline_impressions,
  CASE
    WHEN failures >= 10 AND failure_rate >= 0.25 THEN 'high_failure_rate'
    WHEN baseline_impressions >= 10 AND impressions < baseline_impressions * 0.5 THEN 'impression_drop'
  END AS alert_type
FROM scored
WHERE event_day = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
  AND (
    (failures >= 10 AND failure_rate >= 0.25)
    OR (baseline_impressions >= 10 AND impressions < baseline_impressions * 0.5)
  );
