-- Deploy side7v5:populate_credit_values to mysql
-- requires: credit_values
-- requires: appuser

BEGIN;

INSERT INTO credit_values
  ( name, description, value )
VALUES
  ( 'add_submission', 'User uploads a new submission.', 10 ),
  ( 'favorite_submission', 'User favorited another user\'s work.', 1 ),
  ( 'post_critique', 'User leaves a critique for another user\'s work.', 3 ),
  ( 'post_comment', 'User leaves a comment for another user\'s work.', 1 ),

  ( 'forum_thread_start', 'User starts a new forum thread.', 5 ),
  ( 'forum_post', 'User posts in another user\'s thread.', 1 ),
  ( 'forum_thread_hot', 'User\'s thread becomes hot.', 10 ),

  ( 'new_user_referral', 'A new user listed this member as a referral.', 25 ),
  ( 'add_to_museum', 'User adds another member to their Museum.', 5 ),
  ( 'add_friend', 'User adds another member as a friend.', 3 ),
  ( 'create_group', 'User creates a user group.', 10 ),
  ( 'join_group', 'User joins a user group they didn\'t start.', 5 ),

  ( 'abuse_reward', 'User\'s abuse report is accepted as valid.', 25 ),

  ( 'upvote_submission', 'User upvotes another member\'s submission', -1 ),
  ( 'downvote_submission', 'User downvotes another member\'s submission', -5 ),
  ( 'account_suspension', 'User\'s account is suspended for administrative reasons.', -100 )
;

COMMIT;
