CREATE TABLE github_pr_reviews (
    pr_id            NUMBER PRIMARY KEY,
    repo_name        VARCHAR2(200),
    is_gpt_assisted  NUMBER(1),
    time_to_merge_hr NUMBER(10,2),
    pr_comment       VARCHAR2(2000),
    comment_vector   VECTOR(384, FLOAT32)
);

CREATE VECTOR INDEX idx_pr_comment_hnsw
ON github_pr_reviews (comment_vector)
ORGANIZATION INMEMORY NEIGHBOR GRAPH
DISTANCE COSINE
WITH TARGET ACCURACY 95;

SELECT pr_id, repo_name, time_to_merge_hr, pr_comment
FROM github_pr_reviews
WHERE is_gpt_assisted = 1
ORDER BY VECTOR_DISTANCE(comment_vector, :query_vector, COSINE)
FETCH APPROX FIRST 5 ROWS ONLY;
