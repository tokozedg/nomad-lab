service {
  name = "mysql"
  port = 3306
  tags = ["primary"]                                                                                                                              
  check {
    id       = "mysql-check"
    name     = "MySQL TCP on port 3306"                                                                                                               tcp      = "localhost:3306"
    interval = "10s"                                                                                                                                  timeout  = "1s"
  }
}