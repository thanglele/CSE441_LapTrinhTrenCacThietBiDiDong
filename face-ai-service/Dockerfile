# Dùng base image của Python
FROM python:3.10-slim

RUN apt-get update && apt-get install -y \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Cài đặt thư viện Python
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy code
COPY app.py .

# Mở cổng 5001
EXPOSE 5001

# Lệnh chạy khi container khởi động
CMD ["python", "app.py"]