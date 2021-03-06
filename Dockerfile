# https://hub.docker.com/_/microsoft-dotnet
# FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build
FROM mcr.microsoft.com/dotnet/sdk:5.0-buster-slim AS build
WORKDIR /source

# copy csproj and restore as distinct layers
COPY *.sln .
COPY ScraperService.Grpc/*.csproj ./ScraperService.Grpc/
COPY ScraperService.Infrastructure/*.csproj ./ScraperService.Infrastructure/
COPY ScraperService.Core/*.csproj ./ScraperService.Core/
COPY ScrapeService.Console/*.csproj ./ScrapeService.Console/
RUN dotnet restore

# copy everything else and build app
COPY . .
WORKDIR /source/ScraperService.Grpc
RUN dotnet publish -c release -o /app --no-restore

# final stage/image
FROM mcr.microsoft.com/dotnet/aspnet:5.0
WORKDIR /app
COPY --from=build /app ./
ENTRYPOINT ["dotnet", "ScraperService.Grpc.dll"]

ENV ASPNETCORE_URLS=http://+:5001