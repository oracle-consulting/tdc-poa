sudo mysql <<EOF
create user wpress_user@localhost identified by 'welcomeTDC';
grant all privileges on *.* to wpress_user@localhost;
EOF
