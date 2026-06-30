# E-commerce Email Engagement Analysis

## Project Overview
This project analyzes account creation and email engagement for an e-commerce platform.  
The goal was to prepare a dataset in BigQuery using SQL and build a Looker Studio dashboard to compare user activity across countries.

## Tools
- SQL
- Google BigQuery
- Looker Studio
- Data Visualization

## Dataset
The analysis is based on an e-commerce database with account, session, email sent, email open and email visit data.

## Key Metrics
- account_cnt — number of created accounts
- sent_msg — number of sent emails
- open_msg — number of opened emails
- visit_msg — number of email link visits
- total_country_account_cnt — total accounts by country
- total_country_sent_cnt — total sent emails by country
- rank_total_country_account_cnt — country rank by created accounts
- rank_total_country_sent_cnt — country rank by sent emails

## SQL Logic
The SQL query uses CTEs to calculate account metrics and email metrics separately, then combines them with UNION ALL.  
Window functions are used to calculate country-level totals and rankings.

## Dashboard
The Looker Studio dashboard shows:
- total subscribers
- new subscribers
- unsubscribed accounts
- verified accounts
- email sending preference
- accounts created by country
- ranking by total accounts and emails sent
- email sending dynamics over time

## Result
The final dashboard helps compare user activity between countries, identify key markets, and analyze email engagement trends over time.
