FROM python:3.7.3
RUN pip3 install --upgrade pandas-datareader scipy boto3 yfinance
COPY queue_processor.py queue_processor.py
COPY worker.py worker.py
CMD ["python3", "queue_processor.py"]
