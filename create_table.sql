-- -----------------------------------------------------
-- Schemas oquiz
-- -----------------------------------------------------

-- Note 1 : par convention on va nommer toutes les tables au singulier, en minuscule et en anglais.

-- Note 2 : Chaque table contiendra un champs created_at contenant la date de création d'un enregistrement
-- et un champ updated_at contenant la date de mise à jour de cet enregistrement


BEGIN;
-- Note : BEGIN déclare le début d'une transaction : un groupe d'instructions SQL qui rend celles-ci dépendantes les unes des autres. 
-- Si au moins une des instructions génère une erreur, alors toutes les commandes sont invalidées.


-- Comme c'est un script de création de tables, on s'assure que celles-ci sont bien supprimées avant de les créer. 
-- On peut supprimer plusieurs tables en même temps, cela permet de ne pas avoir de soucis de contraintes de clés étrangères.
-- Note : attention à ne pas lancer ce script en production en revanche :wink:
DROP TABLE IF EXISTS "level",
"answer",
"user",
"quiz",
"question",
"tag",
"quiz_has_tag";

-- -----------------------------------------------------
-- Table "level"
-- -----------------------------------------------------
CREATE TABLE "level" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY, 
  "name" text NOT NULL,
  "created_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz
);

/*
Notes :

- Dans une table on mettra en général 3 champs techniques

  - "id" qui servira de clé primaire et assurera l'unicité de chaque enregistrement : 
    - La clé primaire est automatiquement NOT NULL. Pas besoin de le préciser.
    - On spécifie que la colonne sera générée automatiquement par la BDD en suivant une séquence numérique prédéfinie, s'incrémentant de 1 en 1.
    - On peut définir 'BY DEFAULT' (surcharge de la valeur possible) ou 'ALWAYS' (surcharge de la valeur impossible)
    - Ici on utilise BY DEFAULT, car on définit nous même les valeurs des clés primaires (dans le fichier de seeding).
    - Mais on utilisera plus généralement ALWAYS afin de sécurisé l'incrémentation des valeurs du champ

  - "created_at" qui permet de savoir à quel moment a été inséré cet enregistrement dans cette BDD
    - Le type d'une date sera toujours timestamptz car une date n'a de valeur que si on connait sont contexte (le fuseau horaire)
    - CURRENT_TIMESTAMP (standard SQL) : on peut aussi utiliser now() sur postgreSQL

  - "updated_at" permet quand a lui, de connaitre la date de la dernière mise à jour

*/


-- -----------------------------------------------------
-- Table "user"
-- -----------------------------------------------------
CREATE TABLE "user" (
  "id" integer GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "email" varchar(255) NOT NULL,
  "password" text NOT NULL,
  "rule" text NOT NULL,
  "firstname" text NULL,
  "lastname" text NULL,
  "created_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz
);

-- ATTENTION : ne pas oublier les guillemets double, car autrement le mot user en Postgres est réservé !

-- -----------------------------------------------------
-- Table "quiz"
-- -----------------------------------------------------
CREATE TABLE quiz (
  "id" integer GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "title" text NOT NULL UNIQUE,
  "description" text NULL,
  "author_id" integer NOT NULL REFERENCES "user"("id"),
  "created_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz
);

/*
Notes : 

- Le type de la colonne content une clé étrangère doit toujours être du même type que la colonne à laquelle elle fait référence.
- Ici le fait de ne spécifier que REFERENCES va amener prostgreSQL à créer une contrainte de clé étrangère automatiquement en lui fournissant le nom automatiquement
    CONSTRAINT "user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "user"("id")
*/

-- -----------------------------------------------------
-- Table "question"
-- -----------------------------------------------------
CREATE TABLE question (
  "id" integer GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "description" text NOT NULL,
  "anecdote" text NULL,
  "wiki" text NULL,
  "level_id" integer NOT NULL REFERENCES "level"("id"),
  "quiz_id" integer NOT NULL REFERENCES "quiz"("id"),
  "created_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz
);

-- -----------------------------------------------------
-- Table "answer"
-- -----------------------------------------------------
CREATE TABLE answer (
  "id" integer GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "description" text NOT NULL,
  "question_id" integer NOT NULL REFERENCES "question"("id"),
  "is_valid" boolean NOT NULL DEFAULT false,
  "created_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz
);

-- -----------------------------------------------------
-- Table "tag"
-- -----------------------------------------------------
CREATE TABLE tag (
  "id" integer GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  "name" text NOT NULL UNIQUE,
  "created_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz
);

-- -----------------------------------------------------
-- Table "quiz_has_tag"
-- -----------------------------------------------------
CREATE TABLE quiz_has_tag (
  "quiz_id" integer NOT NULL REFERENCES "quiz"("id"),
  "tag_id" integer NOT NULL REFERENCES "tag"("id"),
  "created_at" timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" timestamptz,
  PRIMARY KEY ("quiz_id", "tag_id")
);
-- PRIMARY KEY créé une clé primaire composite : il ne peut pas y avoir deux fois un enregistrement avec le meme couple "quiz_id"/"tag_id"


COMMIT; -- Pour mettre fin à au bloc de transaction et l'exécuter
/*

Notes : 

- Si jamais la moindre erreur se produit lors de l'exécution de la transaction, postgreSQL effectuera un ROLLBACK et toutes les actions seront annulées.
- Attention : dans le cas d'ajout de données à travers une transaction l'incrémentation de la colonne identité (GENERATED {BY DEFAULT|ALWAYS} AS IDENTITY) n'est pas remise à son point de départ par le rollback. Il n'a pas conservé son état de départ avant la transaction. Cela n'a aucun impact sur le fonctionnement normal de la BDD, les ids non pas forcément besoin de se suivre.

*/
