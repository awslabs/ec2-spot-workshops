FROM python:3.9-slim-bullseye

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
    curl \
    sudo \
    zip \
    python3

#RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
#    unzip awscliv2.zip && \
#    sudo ./aws/install && \
#    rm ./aws/install

RUN curl "https://raw.githubusercontent.com/magriggs/QuantLib.AutoCallable.Memory.Coupon.Note/master/Autocallable.Note.py" -o "Autocallable.Note.py"

ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install dependencies:
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY ./montecarlo-price.sh /
RUN chmod +x /montecarlo-price.sh

ENTRYPOINT ["/montecarlo-price.sh"]


