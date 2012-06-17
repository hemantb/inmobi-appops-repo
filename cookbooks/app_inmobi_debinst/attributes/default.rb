set[:app][:ip] = node[:cloud][:private_ips][0]

set_unless[:app_inmobi_debinst][:service] = nil
set_unless[:app_inmobi_debinst][:startcmd] = nil
set_unless[:app_inmobi_debinst][:stopcmd] = nil
set_unless[:app_inmobi_debinst][:restart] = "false"
set_unless[:app_inmobi_debinst][:debians] = nil
set_unless[:app_inmobi_debinst][:latest] = "false"
