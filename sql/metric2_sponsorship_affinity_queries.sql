-- Metric 2: Sponsorship Affinity Analysis
-- Purpose: Compare fan engagement between organic and sponsored posts

CREATE TABLE metric2_posts (
    team TEXT,
    post_type TEXT,
    description TEXT,
    likes INT,
    comments INT,
    engagement INT,
    reposted INT,
    shared INT
);

-- Check imported data
SELECT * FROM metric2_posts;

-- Clean empty rows
DELETE FROM metric2_posts
WHERE team IS NULL;

-- Overall organic vs sponsored engagement
SELECT
    post_type,
    ROUND(AVG(engagement), 2) AS avg_engagement
FROM metric2_posts
GROUP BY post_type;

-- Team-level organic vs sponsored averages
SELECT
    team,
    ROUND(AVG(CASE WHEN post_type = 'Organic' THEN engagement END), 2) AS organic_avg,
    ROUND(AVG(CASE WHEN post_type = 'Sponsored' THEN engagement END), 2) AS sponsored_avg
FROM metric2_posts
GROUP BY team
ORDER BY team;

-- Sponsorship Affinity Score
-- Formula:
-- Sponsored Avg / (Sponsored Avg + Organic Avg) * 100

WITH metric2_summary AS (
    SELECT
        team,
        AVG(CASE WHEN post_type = 'Organic' THEN engagement END) AS organic_avg,
        AVG(CASE WHEN post_type = 'Sponsored' THEN engagement END) AS sponsored_avg
    FROM metric2_posts
    GROUP BY team
)

SELECT
    team,
    ROUND(organic_avg, 2) AS organic_avg,
    ROUND(sponsored_avg, 2) AS sponsored_avg,
    ROUND(
        (
            sponsored_avg / NULLIF((sponsored_avg + organic_avg), 0)
        ) * 100,
        2
    ) AS sponsorship_affinity_score
FROM metric2_summary
WHERE organic_avg > 0
ORDER BY sponsorship_affinity_score DESC;