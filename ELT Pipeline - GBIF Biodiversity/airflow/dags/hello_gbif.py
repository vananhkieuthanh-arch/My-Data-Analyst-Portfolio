from datetime import datetime
from airflow import DAG
from airflow.operators.bash import BashOperator

with DAG (
    dag_id="hello-gbif",
    start_date=datetime(2024, 1, 1),
    schedule=None,    # manual only
    catchup=False,
    tags=["smoke"],
) as dag:

    BashOperator(
        task_id="ping",
        bash_command='echo "Airflow can see mounted code:" && ls /opt/airflow/src && ls /opt/airflow/dbt_project', 
    )