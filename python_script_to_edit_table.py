#importing some important python modules
import sys
import os
import csv
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from prettytable import PrettyTable
import subprocess
import socket

#Getting the hostname of the system
hostname = socket.gethostname()

master_sheet_file_name="master_sheet"
#Creating a filename for the csv file using the hostname
master_sheet = "{}.csv".format(master_sheet_file_name)

#Changing the current working directory to a specific folder
#os.chdir('/home/sa-jan-mvp/overall-monitoring-report')
os.chdir('/directory_path_of_where_CSV_files_and_Scripts_are_Present')
#present working directory
pwd=os.getcwd()

with open(master_sheet, "w") as outfile:
    header_written = False
    for filename in os.listdir():
        if filename.endswith(".csv"):
            with open(filename, "r") as infile:
                for line in infile:
                    if not header_written:
                        outfile.write(line)
                        header_written = True
                    else:
                        outfile.write(line)



#Initializing a table header using the 'prettytable' module
table_header = PrettyTable()
table_header.field_names = ["Account", "Hostname", "Disk_Space", "Total_Memory", "Free_Memory", "Free_Memory_Status", "Service", "Uptime", "Comment"]

#Reading the data from the csv file
with open(master_sheet, "r") as file:
    header = file.readline()
    for line in file:
        if line.strip() == header.strip():
            continue
        values = line.strip().split("\t")
        table_header.add_row(values)

print(table_header)

try:
    my_message1 = table_header.get_html_string()

    html1 = """\
    <html>
        <head>
            <style>
                table{
                    font-size:12px;
                    color: #333333;
                    border-width: 1px;
                    border-color: #000000;
                    border-collapse: collapse;
                }
                th {
                    font-size:15px;
                    background-color:#acc8cc;
                    border-width: 1px;
                    padding: 8px;
                    border-style: solid;
                    border-color: #000000;
                    text-align:left;
                }
                tr {
                    background-color: #FFFFFF;
                }
                td {
                    font-size:13px;
                    border-width: 1px;
                    padding: 8px;
                    border-style: solid;
                    border-color: #8c8c8c;
                    text-align:center;
                    color: #000000;
                    font-weight: bold;
                }
            </style>
        </head>
        <body>
            <table>
               <br><br> %s
            </table>
        </body>
    </html>
    """ %(my_message1)
    #part1 = MIMEText(text, 'plain')
    part2 = MIMEText(html1, 'html')
    msg = MIMEMultipart('alternative')
    #msg.attach(part1)
    msg.attach(part2)
    #Converting the table to a string representation
    #table_string = part2.as_string()
    table_string = part2.as_string().split('\n\n', 1)[1]
    #Running a shell script to send an email
    with open("output.html", "w") as f:
        f.write(table_string)

    os.chdir(pwd)
    bash_script_path = "./mailing.sh"
    subprocess.call(["bash", bash_script_path])
    #os.remove(pwd + "/" + master_sheet)
    #os.remove(pwd + "/" + output.html)

except Exception as e:
    print('Something went wrong...')
    print(e)
