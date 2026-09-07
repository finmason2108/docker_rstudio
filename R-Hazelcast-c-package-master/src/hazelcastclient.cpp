//  HazelcastClient.cpp

#include "hazelcastclient.h"
// after hazelcastclient.h, so the Hazelcast headers are parsed before R's headers
// remap names such as length and error
#include <Rcpp.h>

HazelcastClient::HazelcastClient(std::string ip, std::string clusterName, int port)
{
  this->ip = ip;
  this->port = port;
  this->clusterName = clusterName;
  hazelcast::client::client_config config;
  config.set_cluster_name(this->clusterName).get_network_config().add_address({this->ip, this->port});
  config.get_connection_strategy_config().get_retry_config().set_cluster_connect_timeout(std::chrono::seconds(30));
  this->hz.reset(new hazelcast::client::hazelcast_client(hazelcast::new_client(std::move(config)).get()));
  this->mapName = "map";
  this->verboseMode = false;
  this->map = this->hz->get_map(mapName).get();
}

std::vector<hazelcast::byte> HazelcastClient::Get(const std::string &key)
{
  auto value = this->map->get<std::string, std::vector<hazelcast::byte>>(key).get();
  if (!value) {
    throw std::invalid_argument("HZ error: can not find key: " + key + " at " + GetUrl());
  }
  if (this->verboseMode) {
    Rcpp::Rcout << "Successfully fetched HZ value: " << this->mapName << "/" << key << "\n";
  }
  return std::move(*value);
}

// Returns an empty vector when the key is absent. Callers that treat a miss as a
// normal condition use this instead of Get(), which throws.
std::vector<hazelcast::byte> HazelcastClient::TryGet(const std::string &key)
{
  auto value = this->map->get<std::string, std::vector<hazelcast::byte>>(key).get();
  if (!value) {
    return std::vector<hazelcast::byte>();
  }
  return std::move(*value);
}

std::string HazelcastClient::GetUrl() {
  return this->ip + ":" + std::to_string(this->port) + "/" + this->mapName;
}

void HazelcastClient::Put(const std::string &key, const std::vector<hazelcast::byte> &value)
{
  this->map->put<std::string, std::vector<hazelcast::byte>>(key, value).get();
}

void HazelcastClient::SetMap(const std::string &mapName)
{
  this->mapName = mapName;
  this->map = hz->get_map(this->mapName).get();
}

void HazelcastClient::SetVerboseMode(bool verboseMode)
{
  this->verboseMode = verboseMode;
}