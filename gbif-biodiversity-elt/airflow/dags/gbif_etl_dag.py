# One DAG = one pipeline story. Manual trigger first (schedule=None).
from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator

default_args = {
    "owner": "gbif_learner",
    "retries": 1,
    "retry_delay": timedelta(minutes=2),
}

with DAG(
    dag_id="gbif_etl",
    start_date=datetime(2024, 1, 1),
    schedule="@weekly",    # manual only
    catchup=False,
    default_args=default_args,
    tags=["gbif", "etl"],
) as dag:

    extract = BashOperator(
        task_id="extract_gbif",
        bash_command="cd /opt/airflow && python src/gbif_client.py",
    )

    load = BashOperator(
        task_id="load_raw",
        bash_command="cd /opt/airflow && python src/load_raw.py",
    )

    dbt_run = BashOperator(
        task_id="dbt_run",
        bash_command=(
            "cd /opt/airflow/dbt_project && "
            "dbt run --profiles-dir /opt/airflow/dbt_project"
        ),
    )

    dbt_test = BashOperator(
        task_id="dbt_test",
        bash_command=(
            "cd /opt/airflow/dbt_project && "
            "dbt test --profiles-dir /opt/airflow/dbt_project"
        ),
    )

    extract >> load >> dbt_run >> dbt_test