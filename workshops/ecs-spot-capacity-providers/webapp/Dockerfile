FROM amazonlinux:latest

RUN yum update -y

RUN yum -y install python3 python3-wheel python-pi

COPY / /app
 
WORKDIR /app

RUN pip3 install -r requirements.txt

ENTRYPOINT ["python3"]
EXPOSE 80
CMD ["app.py"]
