package org.dcm4che3.tool.storescp;

import java.io.File;
import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.hbase.HColumnDescriptor;
import org.apache.hadoop.hbase.HTableDescriptor;
import org.apache.hadoop.hbase.MasterNotRunningException;
import org.apache.hadoop.hbase.TableName;
import org.apache.hadoop.hbase.ZooKeeperConnectionException;
import org.apache.hadoop.hbase.client.HBaseAdmin;
import org.apache.hadoop.hbase.client.HTableInterface;
import org.apache.hadoop.hbase.client.Put;
import org.dcm4che3.data.Attributes;
import org.dcm4che3.data.DatasetWithFMI;
import org.dcm4che3.data.Tag;
import org.dcm4che3.data.VR;
import org.dcm4che3.io.DicomInputStream;
import org.dcm4che3.io.DicomOutputStream;
import org.dcm4che3.io.DicomInputStream.IncludeBulkData;
import org.dcm4che3.net.Association;
import org.dcm4che3.net.Commands;
import org.dcm4che3.net.PDVInputStream;
import org.dcm4che3.net.Status;
import org.dcm4che3.net.pdu.PresentationContext;
import org.dcm4che3.net.service.BasicCStoreSCP;
import org.dcm4che3.net.service.DicomServiceException;
import org.dcm4che3.util.AttributesFormat;
import org.dcm4che3.util.SafeClose;

import com.google.common.primitives.Longs;
import java.math.BigInteger;
import pt.uminho.haslab.safecloudclient.shareclient.SharedAdmin;


public abstract class HBaseStore extends BasicCStoreSCP {

	private File file;
	// patient
	private String patientID;
	private String patientName;
	private Long patientBirthDate;
	private String patientGender;
	private String patientWeight;
	private String patientHistory;
	// image
	private String SOPInstanceUID;
	private String imageType;
	private Long imageDate;
	private Long imageHour;
	// private String imageTSUID;
	// study
	private String studyUID;
	private Long studyDate;
	private Long studyHour;
	private String studyDescription;
	// serie
	private String seriesUID;
	private Long seriesDate;
	private Long seriesHour;
	private String seriesModality;
	private String seriesManufacturer;
	private String seriesInstitution;
	private String seriesRefPhysician;
	private String seriesDescription;
	private final HBaseAdmin admin;
	//private final SharedAdmin admin;
    private HTableInterface tableInterface;
	Configuration conf;
	private int status;
	private String tsuid;
	// HDFSClient hdfsClient = new HDFSClient();
	private final String storageDir;
	private AttributesFormat filePathFormat;
	private static File imagePath;

	public HBaseStore(String file, String storageDir)
			throws MasterNotRunningException, ZooKeeperConnectionException, IOException {
		super("*");
		conf = new Configuration();
		conf.addResource(file);
        System.out.println("Settings are " + file + ":"+storageDir);
          admin = new HBaseAdmin(conf);
        //admin = new SharedAdmin(conf);
		this.storageDir = storageDir;
	}

	public void setStatus(int status) {
		this.status = status;
	}

	@Override
	protected void store(Association as, PresentationContext pc, Attributes rq, PDVInputStream data, Attributes rsp)
			throws IOException {

		tsuid = pc.getTransferSyntax();

		//Attributes fmi = data.readDataset(tsuid);

		// OutputStream out = new
		// FileOutputStream(fmi.getString(Tag.SOPInstanceUID));
		// data.copyTo(out);
		// out.close();

		saveImage(as, pc, rq, data, Commands.mkCStoreRSP(rq, Status.Success));
		rsp.setInt(Tag.Status, VR.US, status);
		DicomInputStream dis = new DicomInputStream (imagePath);
		DatasetWithFMI dataWithFMI = dis.readDatasetWithFMI();
		Attributes fmi = dataWithFMI.getDataset();

		try {
			createHBaseTable();
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		fillTable(fmi);

	}

	public abstract HTableInterface createTableInterface(Configuration conf, String tableName) throws Exception;

	private void createHBaseTable() throws Exception {
		String tableName = "DicomTable";

		// table

		TableName tbname = TableName.valueOf(tableName);
		HTableDescriptor table = new HTableDescriptor(tbname);
		// HColumnDescriptor family = new HColumnDescriptor(columnDescriptor);
		//

		HColumnDescriptor patientFamily = new HColumnDescriptor("Patient");
		HColumnDescriptor imageFamily = new HColumnDescriptor("Image");
		HColumnDescriptor seriesFamily = new HColumnDescriptor("Series");
		HColumnDescriptor studyFamily = new HColumnDescriptor("Study");

		table.addFamily(patientFamily);
		table.addFamily(imageFamily);
		table.addFamily(seriesFamily);
		table.addFamily(studyFamily);

		System.out.println("*************checking table********");
		if (!admin.tableExists(tableName)) {
        //if(!admin.tableExits(tableName)){
            System.out.println("*************creating table**********");
			admin.createTable(table);
			System.out.println("**************table created**************");
		}
		tableInterface = createTableInterface(conf, tableName);
	}

	private void fillTable(Attributes fmi) throws IOException {

		if (fmi.contains(Tag.PatientID)) {
			patientID = fmi.getString(Tag.PatientID);
		}
		if (fmi.contains(Tag.PatientName)) {
			patientName = fmi.getString(Tag.PatientName);
		}
		if (fmi.contains(Tag.PatientBirthDate)) {
			patientBirthDate = fmi.getDate(Tag.PatientBirthDate).getTime();
		}
		if (fmi.contains(Tag.PatientSex)) {
			patientGender = fmi.getString(Tag.PatientSex);
		}
		if (fmi.contains(Tag.PatientWeight)) {
			patientWeight = fmi.getString(Tag.PatientWeight);
		}
		if (fmi.contains(Tag.AdditionalPatientHistory)) {
			patientHistory = fmi.getString(Tag.AdditionalPatientHistory);
		}
		// image
		if (fmi.contains(Tag.SOPInstanceUID)) {
			SOPInstanceUID = fmi.getString(Tag.SOPInstanceUID);
		}
		if (fmi.contains(Tag.ImageType)) {
			imageType = fmi.getString(Tag.ImageType);
		}
		if (fmi.contains(Tag.ContentDate)) {
			imageDate = fmi.getDate(Tag.ContentDate).getTime();
		}
		if (fmi.contains(Tag.ContentTime)) {
			imageHour = ParseTime(fmi.getString(Tag.ContentTime));
		}
		// if(fmi.contains(Tag.TransferSyntaxUID)){
		// imageTSUID = fmi.getString(Tag.TransferSyntaxUID);
		// }
		// study
		if (fmi.contains(Tag.StudyInstanceUID)) {
			studyUID = fmi.getString(Tag.StudyInstanceUID);
		}
		if (fmi.contains(Tag.StudyDate)) {
			studyDate = fmi.getDate(Tag.StudyDate).getTime();
		}
		if (fmi.contains(Tag.StudyTime)) {
			studyHour = ParseTime(fmi.getString(Tag.StudyTime));
		}
		if (fmi.contains(Tag.StudyDescription)) {
			studyDescription = fmi.getString(Tag.StudyDescription);
		}
		// series
		if (fmi.contains(Tag.SeriesInstanceUID)) {
			seriesUID = fmi.getString(Tag.SeriesInstanceUID);
		}
		if (fmi.contains(Tag.SeriesDate)) {
			seriesDate = fmi.getDate(Tag.SeriesDate).getTime();
		}
		if (fmi.contains(Tag.SeriesTime)) {
			seriesHour = ParseTime(fmi.getString(Tag.SeriesTime));
		}
		if (fmi.contains(Tag.Modality)) {
			seriesModality = fmi.getString(Tag.Modality);
		}
		if (fmi.contains(Tag.Manufacturer)) {
			seriesManufacturer = fmi.getString(Tag.Manufacturer);
		}
		if (fmi.contains(Tag.InstitutionName)) {
			seriesInstitution = fmi.getString(Tag.InstitutionName);
		}
		if (fmi.contains(Tag.ReferringPhysicianName)) {
			seriesRefPhysician = fmi.getString(Tag.ReferringPhysicianName); // (0008,0090)
		}
		if (fmi.contains(Tag.SeriesDescription)) {
			seriesDescription = fmi.getString(Tag.SeriesDescription);
		}

		String key = SOPInstanceUID;

		byte[] patientCf = "Patient".getBytes();
		byte[] imageCf = "Image".getBytes();
		byte[] studyCf = "Study".getBytes();
		byte[] seriesCf = "Series".getBytes();

		Put put = new Put(key.getBytes());

		if (!patientID.equals(null)) {
			put.add(patientCf, "ID".getBytes(), patientID.getBytes());
		}
		if (!patientName.equals(null)) {
			put.add(patientCf, "Name".getBytes(), patientName.getBytes());
			put.setAttribute("protected:" + "Patient" + ":Name", "".getBytes());
		}
		if (!patientBirthDate.equals(null)) 
        {
           System.out.println("BirthDate "+this.patientBirthDate);
			put.add(patientCf, "BirthDate".getBytes(), Longs.toByteArray(patientBirthDate));
			put.setAttribute("protected:" + "Patient" + ":BirthDate", "".getBytes());
		}
		if (!patientGender.equals(null)) {
			put.add(patientCf, "Gender".getBytes(), patientGender.getBytes());
		}
		if (!patientWeight.equals(null)) {
           System.out.println("patientWeight "+this.patientWeight);
          
           System.out.println("patientWeight "+new BigInteger(this.patientWeight.getBytes()));
			put.add(patientCf, "Weight".getBytes(), patientWeight.getBytes());
			put.setAttribute("protected:" + "Patient" + ":Weight", "".getBytes());
		}
		if (!patientHistory.equals(null)) {
			// System.out.println("History: "+patientHistory);
			put.add(patientCf, "MedicalHistory".getBytes(), patientHistory.getBytes());
		}
		if (!imageType.equals(null)) {
			put.add(imageCf, "Type".getBytes(), imageType.getBytes());
		}
		if (!imageDate.equals(null)) {
			put.add(imageCf, "Date".getBytes(), Longs.toByteArray(imageDate));
		}
		if (!imageHour.equals(null)) {
			put.add(imageCf, "Time".getBytes(), Longs.toByteArray(imageHour));
		}
		// System.out.println(tsuid);
		if (tsuid != null) {
			// System.out.println("TS: "+tsuid);
			put.add(imageCf, "TransferSyntax".getBytes(), tsuid.getBytes());
		}
		if (!studyUID.equals(null)) {
			put.add(studyCf, "InstanceUID".getBytes(), studyUID.getBytes());
		}
		if (!studyDate.equals(null)) {
			put.add(studyCf, "Date".getBytes(), Longs.toByteArray(studyDate));
		}
		if (!studyHour.equals(null)) {
			put.add(studyCf, "Time".getBytes(), Longs.toByteArray(studyHour));
		}
		if (!studyDescription.equals(null)) {
			put.add(studyCf, "Description".getBytes(), studyDescription.getBytes());
		}
		if (!seriesUID.equals(null)) {
			put.add(seriesCf, "InstanceUID".getBytes(), seriesUID.getBytes());
		}
		if (!seriesDate.equals(null)) {
			put.add(seriesCf, "Date".getBytes(), Longs.toByteArray(seriesDate));
		}
		if (!seriesHour.equals(null)) {
			put.add(seriesCf, "Time".getBytes(), Longs.toByteArray(seriesHour));
		}
		if (!seriesModality.equals(null)) {
			put.add(seriesCf, "Modality".getBytes(), seriesModality.getBytes());
		}
		if (!seriesManufacturer.equals(null)) {
			put.add(seriesCf, "Manufacturer".getBytes(), seriesManufacturer.getBytes());
		}
		if (!seriesInstitution.equals(null)) {
            System.out.println("The instituition "+this.seriesInstitution);
            System.out.println("Intituition "+new BigInteger(this.seriesInstitution.getBytes()));

			put.add(seriesCf, "Institution".getBytes(), seriesInstitution.getBytes());
			put.setAttribute("protected:" + "Series" + ":Institution", "".getBytes());
		}
		if (!seriesRefPhysician.equals(null)) {
            System.out.println("The ref physician "+this.seriesRefPhysician);
            System.out.println("ReferingPhysician "+new BigInteger(this.seriesRefPhysician.getBytes()));
			put.add(seriesCf, "ReferingPhysician".getBytes(), seriesRefPhysician.getBytes());
			put.setAttribute("protected:" + "Series" + ":ReferingPhysician", "".getBytes());
		}
		if (!seriesDescription.equals(null)) {
			put.add(seriesCf, "Description".getBytes(), seriesRefPhysician.getBytes());
		}
		
		tableInterface.put(put);
	}

	private long ParseTime(String timeTag) {
		int len = timeTag.length();
		Long mills;
		if (len == 4) {
			timeTag = new StringBuffer(timeTag).insert(timeTag.length() - 2, ":").toString();
			timeTag = new StringBuffer(timeTag).insert(timeTag.length(), ":00").toString();
		} else if (len == 6) {
			timeTag = new StringBuffer(timeTag).insert(timeTag.length() - 2, ":").toString();
			timeTag = new StringBuffer(timeTag).insert(timeTag.length() - 5, ":").toString();
		} else if (len > 6) {
			timeTag = new StringBuffer(timeTag).insert(3, ":").toString();
			timeTag = new StringBuffer(timeTag).insert(5, ":00").toString();
		} // if none of these conditions are verified, it means that the time
			// format is invalid
		else if (len < 4 || len ==5){
			Date date = new Date();
			return date.getTime();
		}
		SimpleDateFormat formatter = new SimpleDateFormat("hh:mm:ss");
		Date date = new Date();
		try {
			date = (Date) formatter.parse(timeTag);
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		mills = date.getTime();
		return mills;
	}

	// private void insertIntoHDFS (PDVInputStream data, String SOPInstanceUID)
	// throws IOException{
	// byte[] image = IOUtils.toByteArray(data);
	// hdfsClient.putImage(SOPInstanceUID, image);
	// }

	private void saveImage(Association as, PresentationContext pc, Attributes rq, PDVInputStream data, Attributes rsp)
			throws IOException {

		if (storageDir == null)
			return;

		String cuid = rq.getString(Tag.AffectedSOPClassUID);
		String iuid = rq.getString(Tag.AffectedSOPInstanceUID);
		String tsuid = pc.getTransferSyntax();

		File file = new File(storageDir, iuid + ".part");
		try {
			storeTo(as, as.createFileMetaInformation(iuid, cuid, tsuid), data, file);
			renameTo(as, file,
					new File(storageDir, filePathFormat == null ? iuid : filePathFormat.format(parse(file))));
		} catch (Exception e) {
			// deleteFile(as, file);
			throw new DicomServiceException(Status.ProcessingFailure, e);
		}
	}

	private void storeTo(Association as, Attributes fmi, PDVInputStream data, File file) throws IOException {
		file.getParentFile().mkdirs();
		DicomOutputStream out = new DicomOutputStream(file);
		try {
            System.out.println("Attributes to store "+fmi.toString());
			out.writeFileMetaInformation(fmi);
			data.copyTo(out);
		} finally {
			SafeClose.close(out);
		}
	}

	
	private static void renameTo(Association as, File from, File dest) throws IOException {
		imagePath = dest;
		if (!dest.getParentFile().mkdirs())
			dest.delete();
		if (!from.renameTo(dest))
			throw new IOException("Failed to rename " + from + " to " + dest);
	}
	

	private static Attributes parse(File file) throws IOException {
			DicomInputStream in = new DicomInputStream(file);
			try {
				in.setIncludeBulkData(IncludeBulkData.NO);
				return in.readDataset(-1, Tag.PixelData);
			} finally {
				SafeClose.close(in);
			}
		}
}
