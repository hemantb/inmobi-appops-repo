#!/usr/bin/env bash
# 
# Cookbook Name:: inmobi_lb
#

set -e
shopt -s nullglob

CONF_FILE=/opt/mkhoj/conf/lb/inmobi_lb.cfg

cat /opt/mkhoj/conf/lb/inmobi_lb.cfg.head > ${CONF_FILE}

echo "frontend all_requests 127.0.0.1:85" >> ${CONF_FILE}

vhosts=""

for dir in /opt/mkhoj/conf/lb/lb_haproxy.d/*
do
  if [ -d ${dir} ]; then
    vhosts=${vhosts}" "`basename ${dir}`
  fi
done

for single_vhost in ${vhosts}
do
  acl=${single_vhost//\./_}"_acl"
  echo "  acl ${acl} hdr_dom(host) -i ${single_vhost}" >> ${CONF_FILE}
done

echo "" >> ${CONF_FILE}

for single_vhost in ${vhosts}
do
  acl=${single_vhost//\./_}"_acl"
  backend=${single_vhost//\./_}"_backend"
  echo "  use_backend ${backend} if ${acl}" >> ${CONF_FILE}
done

echo "" >> ${CONF_FILE}

cat /opt/mkhoj/conf/lb/inmobi_lb.cfg.default_backend >> ${CONF_FILE}

echo "" >> ${CONF_FILE}

for single_vhost in ${vhosts}
do
  cat /opt/mkhoj/conf/lb/lb_haproxy.d/${single_vhost}.cfg >> ${CONF_FILE}

  if [ $(ls -1A /opt/mkhoj/conf/lb/lb_haproxy.d/${single_vhost} | wc -l) -gt 0 ]; then
    cat /opt/mkhoj/conf/lb/lb_haproxy.d/${single_vhost}/* >> ${CONF_FILE}
  fi

  echo "" >> ${CONF_FILE}

done
