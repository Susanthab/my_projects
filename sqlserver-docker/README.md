
# Download the latest image:
sudo docker pull microsoft/mssql-server-linux

# Run the Docker image:
docker run -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=12qwaszx@' -p 1433:1433 -d microsoft/mssql-server-linux