FROM python:3.6.3
RUN pip install --upgrade pandas-datareader scipy boto3 fix_yahoo_finance
COPY /src/queue_processor.py queue_processor.py
COPY /src/worker.py worker.py
CMD ["python", "queue_processor.py"]