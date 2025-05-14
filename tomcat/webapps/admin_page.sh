#!/bin/bash

find ./ROOT -type f ! -name 'admin_page.sh' -exec \
  sed -i 's|/admin/admin.jsp|/admin/index.jsp|g' {} +