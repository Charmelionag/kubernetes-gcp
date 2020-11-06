provider "google" {
  credentials = file("account.json")
  project     = "orange-293511"
  region      = "europe-west1"
  zone        = "europe-west1-c"
}
