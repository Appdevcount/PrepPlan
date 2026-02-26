# ── Stage 1: build ──────────────────────────────────────────────────────────
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Copy csproj and restore first (layer cache: only re-runs if csproj changes)
COPY SimpleApi.csproj .
RUN dotnet restore

# Copy everything else and publish
COPY . .
RUN dotnet publish -c Release -o /app/publish --no-restore

# ── Stage 2: runtime ─────────────────────────────────────────────────────────
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app

# ASP.NET Core 8+ defaults to port 8080 in containers, modify to expose 80 and 443 instead
ENV ASPNETCORE_HTTP_PORTS=80
# ENV ASPNETCORE_HTTPS_PORTS=443

COPY --from=build /app/publish .


EXPOSE 80
# EXPOSE 443

ENTRYPOINT ["dotnet", "SimpleApi.dll"]
