--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: audits; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE audits (
    id integer NOT NULL,
    auditable_id integer,
    auditable_type character varying,
    associated_id integer,
    associated_type character varying,
    user_id integer,
    user_type character varying,
    username character varying,
    action character varying,
    audited_changes text,
    version integer DEFAULT 0,
    comment character varying,
    remote_address character varying,
    request_uuid character varying,
    created_at timestamp without time zone
);


--
-- Name: audits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE audits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: audits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE audits_id_seq OWNED BY audits.id;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE categories (
    id integer NOT NULL,
    name character varying,
    is_expense boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    "position" integer,
    year integer,
    is_one_percent boolean DEFAULT false
);


--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE categories_id_seq OWNED BY categories.id;


--
-- Name: entries; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE entries (
    id integer NOT NULL,
    date date,
    name character varying,
    document_number character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    journal_id integer,
    is_expense boolean,
    linked_entry_id integer
);


--
-- Name: entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE entries_id_seq OWNED BY entries.id;


--
-- Name: groups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE groups (
    id integer NOT NULL,
    name character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    code character varying
);


--
-- Name: groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE groups_id_seq OWNED BY groups.id;


--
-- Name: groups_units; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE groups_units (
    id integer NOT NULL,
    group_id integer,
    unit_id integer
);


--
-- Name: groups_units_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE groups_units_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: groups_units_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE groups_units_id_seq OWNED BY groups_units.id;


--
-- Name: inventory_entries; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE inventory_entries (
    id integer NOT NULL,
    date date,
    stock_number character varying,
    name character varying,
    document_number character varying,
    amount integer,
    is_expense boolean,
    total_value numeric(9,2),
    unit_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    inventory_source_id integer,
    remark character varying
);


--
-- Name: inventory_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE inventory_entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inventory_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE inventory_entries_id_seq OWNED BY inventory_entries.id;


--
-- Name: inventory_sources; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE inventory_sources (
    id integer NOT NULL,
    name character varying,
    is_active boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: inventory_sources_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE inventory_sources_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inventory_sources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE inventory_sources_id_seq OWNED BY inventory_sources.id;


--
-- Name: items; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE items (
    id integer NOT NULL,
    amount numeric(9,2),
    amount_one_percent numeric(9,2),
    entry_id integer,
    category_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE items_id_seq OWNED BY items.id;


--
-- Name: journal_types; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE journal_types (
    id integer NOT NULL,
    name character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    is_default boolean DEFAULT false
);


--
-- Name: journal_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE journal_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: journal_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE journal_types_id_seq OWNED BY journal_types.id;


--
-- Name: journals; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE journals (
    id integer NOT NULL,
    year integer,
    unit_id integer,
    journal_type_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    is_open boolean,
    initial_balance numeric(9,2) DEFAULT 0 NOT NULL,
    initial_balance_one_percent numeric(9,2) DEFAULT 0.0 NOT NULL
);


--
-- Name: journals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE journals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: journals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE journals_id_seq OWNED BY journals.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: subgroups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE subgroups (
    group_id integer,
    subgroup_id integer
);


--
-- Name: units; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE units (
    id integer NOT NULL,
    name character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    code character varying
);


--
-- Name: units_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE units_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: units_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE units_id_seq OWNED BY units.id;


--
-- Name: user_group_associations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_group_associations (
    id integer NOT NULL,
    group_id integer,
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    can_view_entries boolean DEFAULT false,
    can_manage_entries boolean DEFAULT false,
    can_close_journals boolean DEFAULT false,
    can_manage_users boolean DEFAULT false,
    can_manage_units boolean DEFAULT false,
    can_manage_groups boolean DEFAULT false
);


--
-- Name: user_group_associations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_group_associations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_group_associations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_group_associations_id_seq OWNED BY user_group_associations.id;


--
-- Name: user_unit_associations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_unit_associations (
    unit_id integer,
    user_id integer,
    can_view_entries boolean DEFAULT false,
    can_manage_entries boolean DEFAULT false,
    can_close_journals boolean DEFAULT false,
    can_manage_users boolean DEFAULT false,
    id integer NOT NULL
);


--
-- Name: user_unit_associations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_unit_associations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_unit_associations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_unit_associations_id_seq OWNED BY user_unit_associations.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying,
    last_sign_in_ip character varying,
    confirmation_token character varying,
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    unconfirmed_email character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    invitation_token character varying,
    invitation_sent_at timestamp without time zone,
    invitation_accepted_at timestamp without time zone,
    invitation_limit integer,
    invited_by_id integer,
    invited_by_type character varying,
    is_superadmin boolean DEFAULT false,
    is_blocked boolean DEFAULT false,
    first_name character varying,
    last_name character varying,
    phone character varying,
    invitation_created_at timestamp without time zone
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY audits ALTER COLUMN id SET DEFAULT nextval('audits_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY categories ALTER COLUMN id SET DEFAULT nextval('categories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY entries ALTER COLUMN id SET DEFAULT nextval('entries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY groups ALTER COLUMN id SET DEFAULT nextval('groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY groups_units ALTER COLUMN id SET DEFAULT nextval('groups_units_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY inventory_entries ALTER COLUMN id SET DEFAULT nextval('inventory_entries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY inventory_sources ALTER COLUMN id SET DEFAULT nextval('inventory_sources_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY items ALTER COLUMN id SET DEFAULT nextval('items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY journal_types ALTER COLUMN id SET DEFAULT nextval('journal_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY journals ALTER COLUMN id SET DEFAULT nextval('journals_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY units ALTER COLUMN id SET DEFAULT nextval('units_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_group_associations ALTER COLUMN id SET DEFAULT nextval('user_group_associations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_unit_associations ALTER COLUMN id SET DEFAULT nextval('user_unit_associations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: audits_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY audits
    ADD CONSTRAINT audits_pkey PRIMARY KEY (id);


--
-- Name: categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY entries
    ADD CONSTRAINT entries_pkey PRIMARY KEY (id);


--
-- Name: groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: groups_units_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY groups_units
    ADD CONSTRAINT groups_units_pkey PRIMARY KEY (id);


--
-- Name: inventory_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY inventory_entries
    ADD CONSTRAINT inventory_entries_pkey PRIMARY KEY (id);


--
-- Name: inventory_sources_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY inventory_sources
    ADD CONSTRAINT inventory_sources_pkey PRIMARY KEY (id);


--
-- Name: items_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY items
    ADD CONSTRAINT items_pkey PRIMARY KEY (id);


--
-- Name: journal_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY journal_types
    ADD CONSTRAINT journal_types_pkey PRIMARY KEY (id);


--
-- Name: journals_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY journals
    ADD CONSTRAINT journals_pkey PRIMARY KEY (id);


--
-- Name: units_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY units
    ADD CONSTRAINT units_pkey PRIMARY KEY (id);


--
-- Name: user_group_associations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_group_associations
    ADD CONSTRAINT user_group_associations_pkey PRIMARY KEY (id);


--
-- Name: user_unit_associations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_unit_associations
    ADD CONSTRAINT user_unit_associations_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: associated_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX associated_index ON audits USING btree (associated_id, associated_type);


--
-- Name: auditable_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX auditable_index ON audits USING btree (auditable_id, auditable_type);


--
-- Name: index_audits_on_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_audits_on_created_at ON audits USING btree (created_at);


--
-- Name: index_audits_on_request_uuid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_audits_on_request_uuid ON audits USING btree (request_uuid);


--
-- Name: index_inventory_sources_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_inventory_sources_on_name ON inventory_sources USING btree (name);


--
-- Name: index_units_on_code; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_units_on_code ON units USING btree (code);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON users USING btree (confirmation_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_invitation_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_invitation_token ON users USING btree (invitation_token);


--
-- Name: index_users_on_invited_by_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_invited_by_id ON users USING btree (invited_by_id);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: user_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX user_index ON audits USING btree (user_id, user_type);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20120113112231');

INSERT INTO schema_migrations (version) VALUES ('20120209182807');

INSERT INTO schema_migrations (version) VALUES ('20120324105533');

INSERT INTO schema_migrations (version) VALUES ('20120324120255');

INSERT INTO schema_migrations (version) VALUES ('20120324162141');

INSERT INTO schema_migrations (version) VALUES ('20120324181522');

INSERT INTO schema_migrations (version) VALUES ('20120324182837');

INSERT INTO schema_migrations (version) VALUES ('20120324222812');

INSERT INTO schema_migrations (version) VALUES ('20121027203309');

INSERT INTO schema_migrations (version) VALUES ('20121028150623');

INSERT INTO schema_migrations (version) VALUES ('20121108194410');

INSERT INTO schema_migrations (version) VALUES ('20121124223300');

INSERT INTO schema_migrations (version) VALUES ('20121125210735');

INSERT INTO schema_migrations (version) VALUES ('20121214125518');

INSERT INTO schema_migrations (version) VALUES ('20130119202854');

INSERT INTO schema_migrations (version) VALUES ('20130119213703');

INSERT INTO schema_migrations (version) VALUES ('20130119214432');

INSERT INTO schema_migrations (version) VALUES ('20130119231751');

INSERT INTO schema_migrations (version) VALUES ('20130223093813');

INSERT INTO schema_migrations (version) VALUES ('20130223101108');

INSERT INTO schema_migrations (version) VALUES ('20130223175125');

INSERT INTO schema_migrations (version) VALUES ('20130223205139');

INSERT INTO schema_migrations (version) VALUES ('20130223225456');

INSERT INTO schema_migrations (version) VALUES ('20130317090007');

INSERT INTO schema_migrations (version) VALUES ('20130501195035');

INSERT INTO schema_migrations (version) VALUES ('20130501211540');

INSERT INTO schema_migrations (version) VALUES ('20130713150135');

INSERT INTO schema_migrations (version) VALUES ('20130713154632');

INSERT INTO schema_migrations (version) VALUES ('20130713155709');

INSERT INTO schema_migrations (version) VALUES ('20130812190040');

INSERT INTO schema_migrations (version) VALUES ('20130822194049');

INSERT INTO schema_migrations (version) VALUES ('20130913205729');

INSERT INTO schema_migrations (version) VALUES ('20130925200923');

INSERT INTO schema_migrations (version) VALUES ('20140106210952');

INSERT INTO schema_migrations (version) VALUES ('20140331211018');

INSERT INTO schema_migrations (version) VALUES ('20140414195341');

INSERT INTO schema_migrations (version) VALUES ('20160226193215');

INSERT INTO schema_migrations (version) VALUES ('20160226194900');

INSERT INTO schema_migrations (version) VALUES ('20160226210708');

INSERT INTO schema_migrations (version) VALUES ('20170205203915');

INSERT INTO schema_migrations (version) VALUES ('20170213203638');

INSERT INTO schema_migrations (version) VALUES ('20171228193859');

