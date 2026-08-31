--
-- PostgreSQL database dump
--

-- Dumped from database version 17.5
-- Dumped by pg_dump version 17.5

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: organizations_organization; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.organizations_organization (id, name, logo, about, official_website, contact_email, impact_image1, impact_image2, created_at, updated_at, user_id, title) VALUES (1, 'UNICEF', 'organizations/logos/DIV.png', 'UNICEF works in over 190 countries and territories to save children''s lives, to defend their rights, and to help them fulfill their potential, from early childhood through adolescence. We work tirelessly to reach the world''s most vulnerable and marginalized children.', 'https://www.unicef.org', 'un@gmail.com', 'organizations/impact/gettyimages-672652-1024x1024_1.png', 'organizations/impact/UNI456462_0_1.png', '2026-03-08 06:16:15.443-07', '2026-04-09 15:22:17.865-07', 18, 'Global Aid Organization');
INSERT INTO public.organizations_organization (id, name, logo, about, official_website, contact_email, impact_image1, impact_image2, created_at, updated_at, user_id, title) VALUES (2, 'INTERSOS', 'organizations/logos/DIV2.png', 'INTERSOS provides urgent humanitarian assistance, including healthcare support, protection services, and essential aid for displaced individuals and vulnerable communities. We work tirelessly to reach the world''s most vulnerable populations affected by conflict and disaster.', 'https://www.intersos.org', 'sos@gmail.com', 'organizations/impact/intersos4_1.png', 'organizations/impact/intersos_1.png', '2026-03-08 06:40:31.71-07', '2026-04-09 15:22:17.876-07', 19, 'Humanitarian Aid Organization');
INSERT INTO public.organizations_organization (id, name, logo, about, official_website, contact_email, impact_image1, impact_image2, created_at, updated_at, user_id, title) VALUES (3, 'World Food Programme', 'organizations/logos/Image.png', 'World Food Programme provides essential food assistance and works to prevent malnutrition, supporting vulnerable groups to ensure fair and reliable access to nutrition. We strive to build a world with zero hunger.', 'https://wfpusa.org', 'wfp@gmail.com', 'organizations/impact/wfp4_1.png', 'organizations/impact/wfp1_1.png', '2026-03-08 06:52:51.33-07', '2026-04-09 15:22:17.879-07', 20, 'Global Humanitarian Organization');
INSERT INTO public.organizations_organization (id, name, logo, about, official_website, contact_email, impact_image1, impact_image2, created_at, updated_at, user_id, title) VALUES (4, 'UNHCR', 'organizations/logos/Image4.png', 'UNHCR works to protect refugees and displaced individuals by providing legal support, temporary shelter, essential services, and assistance in asylum and resettlement processes. We strive to save lives and build better futures for millions forced from home.', 'https://give.unrefugees.org', 'uvh@gmail.com', 'organizations/impact/un1_1.png', 'organizations/impact/un5_1.png', '2026-03-08 06:58:24.761-07', '2026-04-09 15:22:17.881-07', 21, 'The UN Refugee Agency');
INSERT INTO public.organizations_organization (id, name, logo, about, official_website, contact_email, impact_image1, impact_image2, created_at, updated_at, user_id, title) VALUES (5, 'World Health Organization', 'organizations/logos/Image5.png', 'World Health Organization provides urgent health guidance, emergency medical support, preventive programs, and field assistance to healthcare systems during crises and disease outbreaks.', 'https://www.who.int', 'who@gmail.com', 'organizations/impact/who6_1.png', 'organizations/impact/who3_1.png', '2026-03-08 07:02:51.917-07', '2026-04-09 15:22:17.884-07', 22, 'Global Health Agency');
INSERT INTO public.organizations_organization (id, name, logo, about, official_website, contact_email, impact_image1, impact_image2, created_at, updated_at, user_id, title) VALUES (6, 'Red Crescent', 'organizations/logos/Image6.png', 'Red Crescent provides urgent medical and humanitarian assistance, including emergency healthcare, food distribution, psychological support, and rapid disaster response for affected communities. We are dedicated to alleviating human suffering, protecting life and health, and upholding human dignity, especially during armed conflicts and other emergencies.', 'https://www.redcross.org', 'red@gmail.com', 'organizations/impact/red3_1.png', 'organizations/impact/red6_1.png', '2026-03-08 07:07:34.617-07', '2026-04-09 15:22:17.886-07', 23, 'Humanitarian Organization');


--
-- Data for Name: organizations_service; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.organizations_service (id, name, description, created_at, updated_at, service_type, icon) VALUES (1, 'Child Protection', 'Providing a safe environment and legal support for children in danger zones.', '2026-03-08 12:26:05.31-07', '2026-04-20 16:07:37.683-07', 'protection', 'shield');
INSERT INTO public.organizations_service (id, name, description, created_at, updated_at, service_type, icon) VALUES (2, 'Education', 'Supporting schools, training teachers, and providing essential educational supplies.', '2026-03-08 12:27:08.794-07', '2026-04-20 16:08:01.165-07', 'education', 'school');
INSERT INTO public.organizations_service (id, name, description, created_at, updated_at, service_type, icon) VALUES (3, 'Water and Sanitation', 'Drilling wells and ensuring access to clean, drinkable water for communities.', '2026-03-08 12:27:18.254-07', '2026-04-20 16:08:35.624-07', 'water', 'water_drop');
INSERT INTO public.organizations_service (id, name, description, created_at, updated_at, service_type, icon) VALUES (4, 'Protection and safety', 'Providing secure environments and legal protection for those in danger zones.', '2026-03-08 12:31:59.109-07', '2026-04-20 16:09:28.017-07', 'protection', 'shield');
INSERT INTO public.organizations_service (id, name, description, created_at, updated_at, service_type, icon) VALUES (5, 'Healthcare and medical services', 'Delivering essential medical services and health interventions.', '2026-03-08 12:32:08.702-07', '2026-04-20 16:09:50.767-07', 'health', 'medical_services');
INSERT INTO public.organizations_service (id, name, description, created_at, updated_at, service_type, icon) VALUES (6, 'Food assistance and essential needs', 'Distributing food assistance and essential non-food items.', '2026-03-08 12:47:05.75-07', '2026-04-20 16:10:10.756-07', 'food', 'restaurant');
INSERT INTO public.organizations_service (id, name, description, created_at, updated_at, service_type, icon) VALUES (7, 'Emergency shelter and crisis support', 'Housing and immediate crisis intervention for displaced families.', '2026-03-08 12:47:17.286-07', '2026-04-20 16:10:23.811-07', 'shelter', 'sos');
INSERT INTO public.organizations_service (id, name, description, created_at, updated_at, service_type, icon) VALUES (8, 'Assistance for children and vulnerable groups', 'Specialized support programs for the most at-risk community members.', '2026-03-08 12:48:47.625-07', '2026-04-20 16:10:58.853-07', 'protection', 'emergency');
INSERT INTO public.organizations_service (id, name, description, created_at, updated_at, service_type, icon) VALUES (9, 'Food Assistance', 'Providing immediate food relief to populations in crisis.', '2026-03-08 12:49:01.797-07', '2026-04-20 16:16:44.84-07', 'food', 'restaurant');
INSERT INTO public.organizations_service (id, name, description, created_at, updated_at, service_type, icon) VALUES (10, 'Malnutrition Prevention', 'Specialized programs to prevent stunting and vitamin deficiencies', '2026-03-08 12:49:13.416-07', '2026-04-20 16:16:31.259-07', 'health', 'health_and_safety');
INSERT INTO public.organizations_service (id, name, description, created_at, updated_at, service_type, icon) VALUES (11, 'Logistics Support', 'Managing supply chains for efficient food distribution globally.', '2026-03-08 12:49:23.197-07', '2026-04-20 16:15:27.649-07', 'logistics', 'local_shipping');
INSERT INTO public.organizations_service (id, name, description, created_at, updated_at, service_type, icon) VALUES (12, 'Maternal Nutrition', 'Specific nutrition programs for children and pregnant women.', '2026-03-08 12:50:08.867-07', '2026-04-20 16:14:42.437-07', 'health', 'pregnant_woman');
INSERT INTO public.organizations_service (id, name, description, created_at, updated_at, service_type, icon) VALUES (13, 'Food Security & Development', 'Building long-term resilience and community development.', '2026-03-08 12:50:17.825-07', '2026-04-20 16:16:54.821-07', 'food', 'grid_view');
INSERT INTO public.organizations_service (id, name, description, created_at, updated_at, service_type, icon) VALUES (14, 'Refugee & IDP Protection', 'Ensuring safety, registration, and identity documentation for displaced populations.', '2026-03-08 12:55:31.039-07', '2026-04-20 16:17:53.979-07', 'protection', 'shield');
INSERT INTO public.organizations_service (id, name, description, created_at, updated_at, service_type, icon) VALUES (15, 'Temporary Shelter', 'Providing essential housing support and temporary accommodation in crisis zones.', '2026-03-08 12:55:48.418-07', '2026-04-20 16:12:53.189-07', 'shelter', 'home');
INSERT INTO public.organizations_service (id, name, description, created_at, updated_at, service_type, icon) VALUES (16, 'Legal Assistance', 'Expert support for asylum services, rights advocacy, and resettlement processes.', '2026-03-08 12:55:57.329-07', '2026-04-20 16:12:06.024-07', 'legal', 'gavel');
INSERT INTO public.organizations_service (id, name, description, created_at, updated_at, service_type, icon) VALUES (17, 'Emergency Relief', 'delivering critical humanitarian aid, food, water, and medical supplies.', '2026-03-08 12:56:38.215-07', '2026-04-20 16:12:23.153-07', 'emergency', 'sos');
INSERT INTO public.organizations_service (id, name, description, created_at, updated_at, service_type, icon) VALUES (18, 'Emergency Response', 'Providing rapid emergency health response during crises.', '2026-03-08 12:57:42.525-07', '2026-04-20 15:55:26.548-07', 'emergency', 'sos');
INSERT INTO public.organizations_service (id, name, description, created_at, updated_at, service_type, icon) VALUES (19, 'Disease Control', 'Monitoring and controlling disease outbreaks and epidemics.', '2026-03-08 12:57:52.928-07', '2026-04-20 15:56:05.474-07', 'health', 'coronavirus');
INSERT INTO public.organizations_service (id, name, description, created_at, updated_at, service_type, icon) VALUES (20, 'Healthcare Systems', 'Strengthening local healthcare infrastructure and support.', '2026-03-08 12:58:02.534-07', '2026-04-20 15:57:05.402-07', 'health', 'local_hospital');
INSERT INTO public.organizations_service (id, name, description, created_at, updated_at, service_type, icon) VALUES (21, 'Vaccination', 'Leading preventive healthcare and vaccination programs.', '2026-03-08 12:58:54.128-07', '2026-04-20 15:57:35.939-07', 'vaccination', 'vaccines');
INSERT INTO public.organizations_service (id, name, description, created_at, updated_at, service_type, icon) VALUES (22, 'Mental Health', 'Providing psychosocial care and mental health support.', '2026-03-08 12:59:05.286-07', '2026-04-20 15:58:26.197-07', 'health', 'psychology');
INSERT INTO public.organizations_service (id, name, description, created_at, updated_at, service_type, icon) VALUES (23, 'Health Education', 'Community guidance and public health education.', '2026-03-08 12:59:17.94-07', '2026-04-20 15:59:23.802-07', 'education', 'Groups_rounded');
INSERT INTO public.organizations_service (id, name, description, created_at, updated_at, service_type, icon) VALUES (24, 'Medical Assistance', 'Emergency healthcare, ambulance services, and medical aid for those in critical need.', '2026-03-08 13:15:13.303-07', '2026-04-20 16:00:18.836-07', 'health', 'medical_services');
INSERT INTO public.organizations_service (id, name, description, created_at, updated_at, service_type, icon) VALUES (25, 'Food Distribution', 'Providing food aid parcels and essential humanitarian supplies to displaced families.', '2026-03-08 13:15:24.983-07', '2026-04-20 16:01:54.315-07', 'food', 'restaurant');
INSERT INTO public.organizations_service (id, name, description, created_at, updated_at, service_type, icon) VALUES (26, 'Psychological Support', 'Mental health services and social support for trauma recovery.', '2026-03-08 13:15:33.412-07', '2026-04-20 16:04:39.699-07', 'health', 'psychology');
INSERT INTO public.organizations_service (id, name, description, created_at, updated_at, service_type, icon) VALUES (27, 'Disaster Response', 'Rapid disaster management and emergency response coordination.', '2026-03-08 13:16:19.447-07', '2026-04-20 16:05:20.175-07', 'emergency', 'warning');
INSERT INTO public.organizations_service (id, name, description, created_at, updated_at, service_type, icon) VALUES (28, 'Health Services', 'Blood donation drives, transfusion services, and first-aid education.', '2026-03-08 13:16:28.251-07', '2026-04-20 16:06:25.83-07', 'health', 'favorite');


--
-- Data for Name: organizations_organizationservice; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.organizations_organizationservice (id, organization_id, service_id) VALUES (1, 1, 1);
INSERT INTO public.organizations_organizationservice (id, organization_id, service_id) VALUES (2, 1, 3);
INSERT INTO public.organizations_organizationservice (id, organization_id, service_id) VALUES (3, 1, 2);
INSERT INTO public.organizations_organizationservice (id, organization_id, service_id) VALUES (4, 2, 4);
INSERT INTO public.organizations_organizationservice (id, organization_id, service_id) VALUES (5, 2, 5);
INSERT INTO public.organizations_organizationservice (id, organization_id, service_id) VALUES (6, 2, 6);
INSERT INTO public.organizations_organizationservice (id, organization_id, service_id) VALUES (7, 2, 7);
INSERT INTO public.organizations_organizationservice (id, organization_id, service_id) VALUES (8, 2, 8);
INSERT INTO public.organizations_organizationservice (id, organization_id, service_id) VALUES (9, 3, 9);
INSERT INTO public.organizations_organizationservice (id, organization_id, service_id) VALUES (10, 3, 10);
INSERT INTO public.organizations_organizationservice (id, organization_id, service_id) VALUES (11, 3, 11);
INSERT INTO public.organizations_organizationservice (id, organization_id, service_id) VALUES (12, 3, 12);
INSERT INTO public.organizations_organizationservice (id, organization_id, service_id) VALUES (13, 3, 13);
INSERT INTO public.organizations_organizationservice (id, organization_id, service_id) VALUES (14, 4, 14);
INSERT INTO public.organizations_organizationservice (id, organization_id, service_id) VALUES (15, 4, 15);
INSERT INTO public.organizations_organizationservice (id, organization_id, service_id) VALUES (16, 4, 16);
INSERT INTO public.organizations_organizationservice (id, organization_id, service_id) VALUES (17, 4, 17);
INSERT INTO public.organizations_organizationservice (id, organization_id, service_id) VALUES (18, 5, 18);
INSERT INTO public.organizations_organizationservice (id, organization_id, service_id) VALUES (19, 5, 19);
INSERT INTO public.organizations_organizationservice (id, organization_id, service_id) VALUES (20, 5, 20);
INSERT INTO public.organizations_organizationservice (id, organization_id, service_id) VALUES (21, 5, 21);
INSERT INTO public.organizations_organizationservice (id, organization_id, service_id) VALUES (22, 5, 12);
INSERT INTO public.organizations_organizationservice (id, organization_id, service_id) VALUES (23, 5, 23);
INSERT INTO public.organizations_organizationservice (id, organization_id, service_id) VALUES (24, 6, 24);
INSERT INTO public.organizations_organizationservice (id, organization_id, service_id) VALUES (25, 6, 25);
INSERT INTO public.organizations_organizationservice (id, organization_id, service_id) VALUES (26, 6, 26);
INSERT INTO public.organizations_organizationservice (id, organization_id, service_id) VALUES (27, 6, 27);
INSERT INTO public.organizations_organizationservice (id, organization_id, service_id) VALUES (28, 6, 28);


--
-- Data for Name: organizations_targetgroup; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.organizations_targetgroup (id, name) VALUES (1, 'Children');
INSERT INTO public.organizations_targetgroup (id, name) VALUES (2, 'Refugees');
INSERT INTO public.organizations_targetgroup (id, name) VALUES (3, 'Mothers');
INSERT INTO public.organizations_targetgroup (id, name) VALUES (4, 'Conflict Zones');
INSERT INTO public.organizations_targetgroup (id, name) VALUES (5, 'Education');
INSERT INTO public.organizations_targetgroup (id, name) VALUES (6, 'IDPs');
INSERT INTO public.organizations_targetgroup (id, name) VALUES (7, 'Women & Children');
INSERT INTO public.organizations_targetgroup (id, name) VALUES (8, 'Disaster Affected');
INSERT INTO public.organizations_targetgroup (id, name) VALUES (9, 'Households in need');
INSERT INTO public.organizations_targetgroup (id, name) VALUES (10, 'Children at risk');
INSERT INTO public.organizations_targetgroup (id, name) VALUES (11, 'Low-income communities');
INSERT INTO public.organizations_targetgroup (id, name) VALUES (12, 'Persecuted Individuals');
INSERT INTO public.organizations_targetgroup (id, name) VALUES (13, 'Displaced Families');
INSERT INTO public.organizations_targetgroup (id, name) VALUES (14, 'Asylum Seekers');
INSERT INTO public.organizations_targetgroup (id, name) VALUES (15, 'Health Emergencies');
INSERT INTO public.organizations_targetgroup (id, name) VALUES (16, 'Outbreak Regions');
INSERT INTO public.organizations_targetgroup (id, name) VALUES (17, 'Vulnerable Individuals');
INSERT INTO public.organizations_targetgroup (id, name) VALUES (18, 'Healthcare Workers');


--
-- Data for Name: organizations_organizationtargetgroup; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.organizations_organizationtargetgroup (id, organization_id, target_group_id) VALUES (1, 1, 1);
INSERT INTO public.organizations_organizationtargetgroup (id, organization_id, target_group_id) VALUES (2, 1, 2);
INSERT INTO public.organizations_organizationtargetgroup (id, organization_id, target_group_id) VALUES (3, 1, 4);
INSERT INTO public.organizations_organizationtargetgroup (id, organization_id, target_group_id) VALUES (4, 1, 5);
INSERT INTO public.organizations_organizationtargetgroup (id, organization_id, target_group_id) VALUES (5, 1, 3);
INSERT INTO public.organizations_organizationtargetgroup (id, organization_id, target_group_id) VALUES (6, 2, 2);
INSERT INTO public.organizations_organizationtargetgroup (id, organization_id, target_group_id) VALUES (7, 2, 6);
INSERT INTO public.organizations_organizationtargetgroup (id, organization_id, target_group_id) VALUES (8, 2, 7);
INSERT INTO public.organizations_organizationtargetgroup (id, organization_id, target_group_id) VALUES (9, 2, 8);
INSERT INTO public.organizations_organizationtargetgroup (id, organization_id, target_group_id) VALUES (10, 3, 9);
INSERT INTO public.organizations_organizationtargetgroup (id, organization_id, target_group_id) VALUES (11, 3, 10);
INSERT INTO public.organizations_organizationtargetgroup (id, organization_id, target_group_id) VALUES (12, 3, 11);
INSERT INTO public.organizations_organizationtargetgroup (id, organization_id, target_group_id) VALUES (13, 3, 2);
INSERT INTO public.organizations_organizationtargetgroup (id, organization_id, target_group_id) VALUES (14, 3, 4);
INSERT INTO public.organizations_organizationtargetgroup (id, organization_id, target_group_id) VALUES (15, 4, 12);
INSERT INTO public.organizations_organizationtargetgroup (id, organization_id, target_group_id) VALUES (16, 4, 13);
INSERT INTO public.organizations_organizationtargetgroup (id, organization_id, target_group_id) VALUES (17, 4, 2);
INSERT INTO public.organizations_organizationtargetgroup (id, organization_id, target_group_id) VALUES (18, 4, 6);
INSERT INTO public.organizations_organizationtargetgroup (id, organization_id, target_group_id) VALUES (19, 4, 14);
INSERT INTO public.organizations_organizationtargetgroup (id, organization_id, target_group_id) VALUES (20, 5, 15);
INSERT INTO public.organizations_organizationtargetgroup (id, organization_id, target_group_id) VALUES (21, 5, 2);
INSERT INTO public.organizations_organizationtargetgroup (id, organization_id, target_group_id) VALUES (22, 5, 16);
INSERT INTO public.organizations_organizationtargetgroup (id, organization_id, target_group_id) VALUES (23, 5, 17);
INSERT INTO public.organizations_organizationtargetgroup (id, organization_id, target_group_id) VALUES (24, 5, 18);
INSERT INTO public.organizations_organizationtargetgroup (id, organization_id, target_group_id) VALUES (25, 6, 1);
INSERT INTO public.organizations_organizationtargetgroup (id, organization_id, target_group_id) VALUES (26, 6, 2);
INSERT INTO public.organizations_organizationtargetgroup (id, organization_id, target_group_id) VALUES (27, 6, 3);
INSERT INTO public.organizations_organizationtargetgroup (id, organization_id, target_group_id) VALUES (28, 6, 4);
INSERT INTO public.organizations_organizationtargetgroup (id, organization_id, target_group_id) VALUES (29, 6, 5);


--
-- Name: organizations_organization_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.organizations_organization_id_seq', 6, true);


--
-- Name: organizations_organizationservice_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.organizations_organizationservice_id_seq', 28, true);


--
-- Name: organizations_organizationtargetgroup_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.organizations_organizationtargetgroup_id_seq', 29, true);


--
-- Name: organizations_service_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.organizations_service_id_seq', 28, true);


--
-- Name: organizations_targetgroup_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.organizations_targetgroup_id_seq', 18, true);


--
-- PostgreSQL database dump complete
--

