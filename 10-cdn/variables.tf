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
        component = "cdn"
        terraform = true
    }
}
variable "zone_name" {
    default = "muvva.online"
}