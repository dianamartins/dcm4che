import argparse
from xml.etree import ElementTree as ET
import os
import shutil
import subprocess
import random


def execute_command(command):
    bash_command = command.split(" ")
    subprocess.call(bash_command)


def generate_dataset (num_replicas, image_path, replicas_folder, dcmodify):

    for i in os.listdir(path=replicas_folder):
        os.remove(replicas_folder + i)

    for i in range(num_replicas):
        # if i.endswith("/"):
            shutil.copy2(image_path, replicas_folder + str(i+1) + '.dcm')
        # else:
          #   shutil.copy2(image_path, replicas_folder + "/" + str(i+1) + ".dcm")
            # print("Replicado!")
    # SOPInstanceUID_tag = "(0008,0018)"
    # StudyInstanceUID_tag = "(0020000D)"
    # SeriesInstanceUID_tag = "(0020,000E)"
    PatientID_tag = "(0010,0020)"
    PatientName_tag = "(0010,0010)"
    PatientAge_tag = "(0010,1010)"
    PatientGender_tag = "(0010,0040)"
    PatientWeight_tag = "(0010,1030)"
    PatientHistory_tag = "(0010,21B0)"
    ImageType_tag = "(0008,0008)"
    ImageDate_tag = "(0008,0023)"
    ImageHour_tag = "(0008,0033)"
    StudyDate_tag = "(0008,0020)"
    StudyHour_tag = "(0008,0030)"
    StudyDescription_tag = "(0008,1030)"
    Modality_tag = "(0008,0060)"
    Manufacturer_tag = "(0008,0070)"
    Institution_tag = "(0008,0080)"
    SeriesDate_tag = "(0008,0021)"
    SeriesHour_tag = "(0008,0031)"
    SeriesDescription_tag = "(0008,103E)"
    ReferingPysician_tag = "(0008,0090)"

    SOPInstanceUID_m = dcmodify + " -gin "
    StudyInstanceUID_m = dcmodify + " -gst "
    SeriesInstanceUID_m = dcmodify + " -gse "
    PatientID_m = dcmodify + " -m " + PatientID_tag + "="
    PatientName_m = dcmodify + " -m " + PatientName_tag + "="
    PatientAge_m = dcmodify + " -m " + PatientAge_tag + "="
    PatientGender_m = dcmodify + " -m " + PatientGender_tag + "="
    PatientWeight_m = dcmodify + " -m " + PatientWeight_tag + "="
    PatientHistory_m = dcmodify + " -m " + PatientHistory_tag + "="
    ImageType_m = dcmodify + " -m " + ImageType_tag + "="
    ImageDate_m = dcmodify + " -m " + ImageDate_tag + "="
    ImageHour_m = dcmodify + " -m " + ImageHour_tag + "="
    StudyDescription_m = dcmodify + " -m " + StudyDescription_tag + "="
    Modality_m = dcmodify + " -m " + Modality_tag + "="
    Manufacturer_m = dcmodify + " -m " + Manufacturer_tag + "="
    Institution_m = dcmodify + " -m " + Institution_tag + "="
    SeriesDate_m = dcmodify + " -m " + SeriesDate_tag + "="
    SeriesHour_m = dcmodify + " -m " + SeriesHour_tag + "="
    SeriesDescription_m = dcmodify + " -m " + SeriesDescription_tag + "="
    ReferingPysician_m = dcmodify + " -m " + ReferingPysician_tag + "="
    StudyDate_m = dcmodify + " -m " + StudyDate_tag + "="
    StudyHour_m = dcmodify + " -m " + StudyHour_tag + "="

    gender = ["M", "F"]
    history = ["COUGH", "HEADACHE", "BACKPAIN", "ABDOMINALPAIN", "BLURREDVISION"]
    description = ["CHEST", "HELICALCHEST", "PELVIS", "HEAD"]
    modality = ["CT", "CR", "PET", "MRI"]
    manufacturer = ["GE", "PHILIPS", "SIEMENS"]
    image_type_v1 = ["ORIGINAL", "DERIVED"]
    image_type_v2 = ["PRIMARY", "SECONDARY"]

    counter = 1
    for j in range(num_replicas):
        i = str(j+1) + ".dcm"
        print i
        execute_command(SeriesInstanceUID_m + replicas_folder + i)
        execute_command(StudyInstanceUID_m + replicas_folder + i)
        execute_command(SOPInstanceUID_m + replicas_folder + i)
        execute_command(PatientID_m + str(counter).zfill(6) + " " + replicas_folder + i)
        # print(PatientID_m + str(counter).zfill(6) + "\' " + replicas_folder + i)
        execute_command(PatientName_m + "PATIENT" + str(counter) + " " + replicas_folder + i)
        execute_command(PatientAge_m + str(random.randint(10, 80)) + " " + replicas_folder + i)
        execute_command(PatientGender_m + random.choice(gender) + " " + replicas_folder + i)
        execute_command(PatientWeight_m + str(random.randint(20, 120)) + " " + replicas_folder + i)
        execute_command(PatientHistory_m + random.choice(history) + " " + replicas_folder + i)
        execute_command(ImageType_m + random.choice(image_type_v1) + "\\" + random.choice(image_type_v2) + " " + replicas_folder + i)
        execute_command(ImageDate_m + str(random.randint(1998, 2016)) + str(random.randint(1, 12)).zfill(2) +
                        str(random.randint(1, 28)).zfill(2) + " " + replicas_folder + i)
        execute_command(ImageHour_m + str(random.randint(8, 23)).zfill(2) + str(random.randint(0, 59)).zfill(2) +
                        str(random.randint(0, 59)).zfill(2) + " " + replicas_folder + i)
        execute_command(StudyDescription_m + random.choice(description) + " " + replicas_folder + i)
        execute_command(Modality_m + random.choice(modality) + " " + replicas_folder + i)
        execute_command(Manufacturer_m + random.choice(manufacturer) + " " + replicas_folder + i)
        execute_command(Institution_m + "INSTITUTION" + str(counter) + " " + replicas_folder + i)
        execute_command(SeriesDate_m + str(random.randint(1998, 2016)) + str(random.randint(1, 12)).zfill(2) +
                        str(random.randint(1, 28)).zfill(2) + " " + replicas_folder + i)
        execute_command(SeriesHour_m + str(random.randint(8, 23)).zfill(2) + str(random.randint(0, 59)).zfill(2) +
                        str(random.randint(0, 59)).zfill(2) + " " + replicas_folder + i)
        execute_command(SeriesDescription_m + random.choice(description) + " " + replicas_folder + i)
        execute_command(ReferingPysician_m + "PHYSICIAN" + str(counter) + " " + replicas_folder + i)
        execute_command(StudyDate_m + str(random.randint(1998, 2016)) + str(random.randint(1, 12)).zfill(2) +
                        str(random.randint(1, 28)).zfill(2) + " " + replicas_folder + i)
        execute_command(StudyHour_m + str(random.randint(8, 23)).zfill(2) + str(random.randint(0, 59)).zfill(2) +
                        str(random.randint(0, 59)).zfill(2) + " " + replicas_folder + i)
        counter += 1

    for i in os.listdir(path=replicas_folder):
        if i.endswith(".bak"):
            os.remove(replicas_folder+i)


if __name__ == '__main__':
    cl_parser = argparse.ArgumentParser(description='Give preferences.xml')
    cl_parser.add_argument('file', help='preferences file', type=str)
    args = cl_parser.parse_args()
    preferences_file = args.file

    tree = ET.parse(preferences_file)
    replicas = tree.find("numreplicas").text
    num_replicas = int(replicas)
    base_image = tree.find("baseImage").text
    replicas_folder = tree.find("replicasFolder").text
    dcmodify = tree.find("dcmodify").text

    generate_dataset(num_replicas, base_image, replicas_folder, dcmodify)