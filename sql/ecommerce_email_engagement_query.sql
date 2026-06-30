-- 1. Розрахунок метрик для акаунта
WITH
account_metrics AS (
  SELECT
    s.date AS date,
    sp.country,
    send_interval,
    is_verified,
    is_unsubscribed,
    COUNT(DISTINCT acs.account_id) AS account_cnt
  FROM data-analytics-mate.DA.session s
  JOIN data-analytics-mate.DA.account_session acs
    ON s.ga_session_id = acs.ga_session_id
  JOIN data-analytics-mate.DA.account a
    ON acs.account_id = a.id
  JOIN data-analytics-mate.DA.session_params sp
    ON s.ga_session_id = sp.ga_session_id
  GROUP BY 1, 2, 3, 4, 5
),




-- 2. Розрахунок метрик для email
email_metrics AS (
  SELECT
    DATE_ADD(s.date, INTERVAL es.sent_date DAY) AS sent_day,
    sp.country,
    send_interval,
    is_verified,
    is_unsubscribed,
    COUNT(DISTINCT es.id_message) AS sent_msg,
    COUNT(DISTINCT eo.id_message) AS open_msg,
    COUNT(DISTINCT ev.id_message) AS visit_msg
  FROM data-analytics-mate.DA.email_sent es
  LEFT JOIN data-analytics-mate.DA.email_open eo
    ON es.id_message = eo.id_message
  LEFT JOIN data-analytics-mate.DA.email_visit ev
    ON eo.id_message = ev.id_message
  JOIN data-analytics-mate.DA.account_session acs
    ON es.id_account = acs.account_id
  JOIN data-analytics-mate.DA.account a
    ON acs.account_id = a.id
  JOIN data-analytics-mate.DA.session s
    ON acs.ga_session_id = s.ga_session_id
  JOIN data-analytics-mate.DA.session_params sp
    ON s.ga_session_id = sp.ga_session_id
  GROUP BY sent_day, sp.country, send_interval, is_verified, is_unsubscribed
),




-- 4. Об'єднання метрик для акаунта та email через UNION
union_metrics AS (
  SELECT
    am.date AS date,
    am.country AS country,
    send_interval,
    is_verified,
    is_unsubscribed,
    account_cnt AS account_cnt,
    0 AS sent_msg,
    0 AS open_msg,
    0 AS visit_msg
  FROM account_metrics am
  UNION ALL
  SELECT
    sent_day AS date,
    em.country AS country,
    send_interval,
    is_verified,
    is_unsubscribed,
    0 AS account_cnt,
    sent_msg AS sent_msg,
    open_msg AS open_msg,
    visit_msg AS visit_msg
  FROM email_metrics em
),




-- 5. Сумування метрик для акаунта та email
sum_account_email_cnt AS (
  SELECT
    date,
    country,
    send_interval,
    is_verified,
    is_unsubscribed,
    SUM(account_cnt) AS account_cnt,
    SUM(sent_msg) AS sent_msg,
    SUM(open_msg) AS open_msg,
    SUM(visit_msg) AS visit_msg
  FROM union_metrics
  GROUP BY date, country, send_interval, is_verified, is_unsubscribed
),




-- 6. Підрахунок загальної кількості створених підписників та відправлених листів в цілому по країні
total_metrics AS (
  SELECT
    *,
    SUM(account_cnt) OVER (PARTITION BY country) AS total_country_account_cnt,
    SUM(sent_msg) OVER (PARTITION BY country) AS total_country_sent_cnt
  FROM sum_account_email_cnt
),




-- 7. рейтинг країн
final AS (
  SELECT
    *,
    DENSE_RANK()
      OVER (ORDER BY total_country_account_cnt DESC)
      AS rank_total_country_account_cnt,
    DENSE_RANK()
      OVER (ORDER BY total_country_sent_cnt DESC)
      AS rank_total_country_sent_cnt
  FROM total_metrics
)
SELECT
date,
country,
send_interval,
is_verified,
is_unsubscribed,
account_cnt,
sent_msg,
open_msg,
visit_msg,
total_country_account_cnt,
total_country_sent_cnt,
rank_total_country_account_cnt,
rank_total_country_sent_cnt
FROM final
WHERE rank_total_country_account_cnt <= 10 OR rank_total_country_sent_cnt <= 10
ORDER BY
date,
country,
rank_total_country_account_cnt DESC,
rank_total_country_sent_cnt DESC;
