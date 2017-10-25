-- Verify side7v5:faq_entries on mysql

BEGIN;

SELECT question, answer
  FROM faq_entries
 WHERE 0;

ROLLBACK;
