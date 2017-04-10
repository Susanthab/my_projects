from st2actions.runners.pythonrunner import Action

class CreateHostsfile(Action):

    def run(self, hosts_list):

        file =open("/etc/ansible/hosts","w")

        file.write("[primary]")
        file.write("\n" + hosts_list[0][0][0])
        file.write("\n" +"")
        file.write("\n" + "[secondary]")

        for ip in hosts_list[1:len(hosts_list)]:
            file.write("\n" + ip[0][0])

        file.write("\n" +"")
        file.write("\n" + "[primary:vars]")
        file.write("\n" + "[db_user_admin_username=mongo_admin]")
        file.write("\n" + "[db_user_admin_password=pssw0rd]")
        file.write("\n" + "[db_cluster_admin_username=mongo_cl_admin]")
        file.write("\n" + "[db_cluster_admin_password=pssw0rd]")
        file.write("\n" + "[db_user_name=susa]")
        file.write("\n" + "[db_user_password=susa123]")
        file.write("\n" + "[db_name=test]")

        file.close()

        return(True)