variable "project_name" {
    type = string
    default = "expense"
}
variable "environment" {
    default = "dev"
}
variable "common_tags" {
    default = {
        project = "expense"
        environment = "dev" 
        terraform = true
        component = "web"
    }
}
variable "zone_name" {
    default = "muvva.online"
}
variable "zone_id" {
    default = "Z09196511SQGIFEK0HWMC"
}