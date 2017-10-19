-- Deploy side7v5:populate_user_genders to mysql
-- requires: user_sexes
-- requires: users
-- requires: appuser

BEGIN;

INSERT INTO user_genders
  ( gender )
VALUES ( 'Unspecified' ), ( 'Agender' ), ( 'Androgyne' ), ( 'Androgynous' ), ( 'Bigender' ), ( 'Cis' ), ( 'Cisgender' ),
       ( 'Cis Female' ), ( 'Cis Male' ), ( 'Cis Man' ), ( 'Cis Woman' ), ( 'Cisgender Female' ), ( 'Cisgender Male' ),
       ( 'Cisgender Man' ), ( 'Cisgender Woman' ), ( 'Female' ), ( 'Female to Male' ), ( 'FTM' ), ( 'Gender Fluid' ),
       ( 'Gender Nonconforming' ), ( 'Gender Questioning' ), ( 'Gender Variant' ), ( 'Genderqueer' ), ( 'Intersex' ),
       ( 'Male' ), ( 'Male to Female' ), ( 'MTF' ), ( 'Neither' ), ( 'Neutrois' ), ( 'Non-binary' ), ( 'Other' ),
       ( 'Pangender' ), ( 'Trans' ), ( 'Trans*' ), ( 'Trans Female' ), ( 'Trans* Female' ), ( 'Trans Male' ), ( 'Trans* Male' ),
       ( 'Trans Man' ), ( 'Trans* Man' ), ( 'Trans Person' ), ( 'Trans* Person' ), ( 'Trans Woman' ), ( 'Trans* Woman' ),
       ( 'Transfeminine' ), ( 'Transgender' ), ( 'Transgender Female' ), ( 'Transgender Male' ), ( 'Transgender Man' ),
       ( 'Transgender Person' ), ( 'Transgender Woman' ), ( 'Transmasculine' ), ( 'Transsexual' ), ( 'Transsexual Female' ),
       ( 'Transsexual Male' ), ( 'Transsexual Man' ), ( 'Transsexual Person' ), ( 'Transsexual Woman' ), ( 'Two-Spirit' );

COMMIT;
