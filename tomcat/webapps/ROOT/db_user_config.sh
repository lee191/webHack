#!/bin/bash

find . -type f -exec sed -i 's|jdbc:mysql://localhost:3306/my_database|jdbc:mysql://172.17.0.1:3306/my_database|g' {} +
