package com.locationdataprocess;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.ByteBuffer;
import java.nio.channels.FileChannel;
import com.datastax.driver.core.BoundStatement;
import com.datastax.driver.core.Cluster;
import com.datastax.driver.core.Host;
import com.datastax.driver.core.Metadata;
import com.datastax.driver.core.PreparedStatement;
import com.datastax.driver.core.ResultSet;
import com.datastax.driver.core.Row;
import com.datastax.driver.core.Session;
 
public class QueryAndUpdateData {
 
    private Cluster cluster;
 
    private Session session;
 
    public Cluster getCluster() {
        return cluster;
    }
 
    public void setCluster(Cluster cluster) {
        this.cluster = cluster;
    }
 
    public Session getSession() {
        return session;
    }
 
    public void setSession(Session session) {
        this.session = session;
    }
 
    /**
     * 连接节点 link node
     * 
     * @param node
     */
    public void connect(String node) {
        cluster = Cluster.builder().addContactPoint(node).build();
        Metadata metadata = cluster.getMetadata();
        System.out.printf("Connected to cluster: %s\n",
                metadata.getClusterName());
        for (Host host : metadata.getAllHosts()) {
            System.out.printf("Datatacenter: %s; Host: %s; Rack: %s\n",
                    host.getDatacenter(), host.getAddress(), host.getRack());
        }
 
        this.session = cluster.connect();
    }
 
    public void insertData(String name) {
        String fileName[]={"Zhengye_DriveTesting_08-18.09-07.txt","Zhengye_DriveTesting_08-18.09-13.txt",
                "Zhengye_DriveTesting_08-18.17-40.txt","Zhengye_DriveTesting_08-18.17-48.txt",
                "Zhengye_DriveTesting_08-19.17-19.txt","Zhengye_DriveTesting_08-20.09-33.txt",
                "Zhengye_DriveTesting_08-20.18-05.txt","Zhengye_DriveTesting_08-19.09-08.txt",
                "Zhengye_DriveTesting_08-21.18-07.txt","Zhengye_DriveTesting_08-21.09-34.txt"
        };
        int n = fileName.length;
        String sqlGPS = "CREATE TABLE IF NOT EXISTS gpsdata.gps ("
                + "time varchar,"
                + "gps_time varchar,longitude varchar,"
                + "latitude varchar,altitude varchar,"
                + "heading varchar,speed varchar,"
                + "source varchar,satellites varchar,"
                + "PRIMARY KEY (time))";
        String sqlTA = "CREATE TABLE IF NOT EXISTS gpsdata.ta ("
                +"time varchar,"
                + "version varchar,"
                + "nRecords varchar,"
                + "nSubFrame varchar,"
                + "nSystemFrame varchar,"
                + "DLFrameTimingOffset varchar,"
                + "ULFrameTimingOffset varchar,"
                + "ULTimingAdvance varchar,"
                + "PRIMARY KEY (time))";
        String sqlDB = "CREATE TABLE IF NOT EXISTS gpsdata.db ("
                +"time varchar,"
                + "version varchar,"
                + "EARFCN varchar,"
                + "CellId varchar,"
                + "nSubFrame varchar,"
                + "RSRP varchar,"
                + "RSRQ varchar,"
                + "NeighborCells varchar,"
                + "DetectedCells varchar,"
                + "NeighborCellId varchar,"
                + "NeighborRSRP varchar,"
                + "NeighborRSRQ varchar,"
                + "PRIMARY KEY (time))";
        String insertGPS = "insert into gpsdata.gps("
                + "time,gps_time,longitude,latitude,"
                + "altitude,heading,speed,"
                + "source,satellites)"
                + " values(?,?,?,?,?,?,?,?,?)";
        String insertTA = "insert into gpsdata.ta("
                +"time,version,nRecords,nSubFrame,nSystemFrame,DLFrameTimingOffset,"
                + "ULFrameTimingOffset,ULTimingAdvance)"
                + " values(?,?,?,?,?,?,?,?)";
        String insertDB = "insert into gpsdata.db("
                +"time,version,EARFCN,"
                + "CellId,nSubFrame,RSRP,"
                + "RSRQ,NeighborCells,DetectedCells,"
                + "NeighborCellId,NeighborRSRP,NeighborRSRQ)"
                + " values(?,?,?,?,?,?,?,?,?,?,?,?)";
        String sql = null, insert=null;
        if(name=="GPS"){
            sql = sqlGPS;
            insert = insertGPS;
        }else if(name=="TA"){
            sql = sqlTA;
            insert = insertTA;
        }else if(name=="DB"){
            sql = sqlDB;
            insert = insertDB;
        }
        getSession().execute(sql);
                
        PreparedStatement psta = getSession().prepare(insert);                     
        BoundStatement boundSta = new BoundStatement(psta);        
        for(int k=0;k<n;k++){
            File file = new File("H:\\项目数据\\Zhengye_Drive_Testing_Data\\"
                    + fileName[k]);
            try {
                FileInputStream fis = new FileInputStream(file);
                InputStreamReader isr = new InputStreamReader(fis);
                BufferedReader br = new BufferedReader(isr);
                String line = null;
                if (name == "GPS") {
                    while ((line = br.readLine()) != null) {
                        String s = line.trim();
                        if (s.contains("3D GPS Info")) {
                            String data[] = new String[9];
                            data[0] = s.substring(0, 25);
                            int i = 0;
                            while (i < 1 && (line = br.readLine()) != null) {
                                if (!line.equals("")) {
                                    data[1] = line.split("=")[1].trim();
                                    // System.out.println(line.trim());
                                    i++;
                                }
                            }
                            // System.out.println(s);
                            i = 0;
                            while (i < 7 && (line = br.readLine()) != null) {
                                if (!line.equals("")) {
                                    data[i + 2] = line.split("=")[1].trim();
                                    // System.out.println(line.trim());
                                    i++;
                                }
                            }
                            getSession().execute(
                                    boundSta.bind(data[0], data[1], data[2],
                                            data[3], data[4], data[5], data[6],
                                            data[7], data[8]));
                        }
                    }
                } else if (name == "TA") {
                    while ((line = br.readLine()) != null) {
                        String s = line.trim();
                        if (s.contains("LTE LL1 Serving Cell Frame Timing")) {
                            String data[] = new String[8];
                            data[0] = s.substring(0, 25);
                            // System.out.println(s);
                            int i = 0;
                            while (i < 7 && (line = br.readLine()) != null) {
                                if (!line.equals("")) {
                                    data[i + 1] = line.split("=")[1].trim();
                                    // System.out.println(line.trim());
                                    i++;
                                }
                            }
                            getSession().execute(
                                    boundSta.bind(data[0], data[1], data[2],
                                            data[3], data[4], data[5], data[6],
                                            data[7]));
                        }
                    }
                } else if(name=="DB"){
                    while ((line = br.readLine()) != null) {
                        String s = line.trim();
                        if (s.contains("LTE ML1 Connected Mode LTE Intra-Freq Meas Results")) {
                            String data[] = new String[12];
                            data[9] = "";
                            data[10] = "";
                            data[11] = "";
                            data[0] = s.substring(0, 25);
                            // System.out.println(s);
                            int i = 0;
                            while (i < 8 && (line = br.readLine()) != null) {
                                if (!line.equals("")) {
                                    data[i + 1] = line.split("=")[1].trim();
                                    // System.out.println(line.trim());
                                    i++;
                                }
                            }
                            int i1 = 0;
                            while (i1 < 6 && (line = br.readLine()) != null) {
                                i1++;
                            }
                            ;
                            while ((line = br.readLine()) != null
                                    && line.contains("|")) {
                                // System.out.println(line);
                                data[i + 1] += line.split("\\|")[2].trim()
                                        + " ";
                                data[i + 2] += line.split("\\|")[3].trim()
                                        + " ";
                                data[i + 3] += line.split("\\|")[4].trim()
                                        + " ";
                            }
                            // System.out.println(data[9]);
                            getSession().execute(
                                    boundSta.bind(data[0], data[1], data[2],
                                            data[3], data[4], data[5], data[6],
                                            data[7], data[8], data[9],
                                            data[10], data[11]));
                        }
                    }
                }
                
                System.out.println(fileName[k]+"插入成功！");
            } catch (FileNotFoundException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            } catch (IOException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
        }
 
    }
    
    //查询TA数据
    public void loadTAData() {
        String select = "select* from gpsdata.ta";
        ResultSet resultSet = getSession().execute(select);
        int count=0;
        for (Row row : resultSet) {
            System.out.println("time: "+row.getString("time"));
            System.out.println("version: "+row.getString("version"));
            System.out.println("nRecords: "+row.getString("nrecords"));
            System.out.println("nSubFrame: "+row.getString("nsubframe"));
            System.out.println("nSystemFrame: "+row.getString("nsystemframe"));
            System.out.println("DLFrameTimingOffset: "+row.getString("dlframetimingoffset"));
            System.out.println("ULFrameTimingOffset: "+row.getString("ulframetimingoffset"));
            System.out.println("ULTimingAdvance: "+row.getString("ultimingadvance")); 
            System.out.println("=========================================================");
            count++;
        }
        System.out.println("行数:"+count);  //print line number
    }

    
    //查询DB数据  query data in db
    public void loadDBData() {
        String select = "select* from gpsdata.db";
        ResultSet resultSet = getSession().execute(select);
        int count=0;
        for (Row row : resultSet) {
            System.out.println("time: "+row.getString("time"));
            System.out.println("version: "+row.getString("version"));
            System.out.println("EARFCN: "+row.getString("earfcn"));
            System.out.println("CellId: "+row.getString("cellid"));
            System.out.println("nSubFrame: "+row.getString("nsubframe"));
            System.out.println("RSRP: "+row.getString("rsrp"));
            System.out.println("RSRQ: "+row.getString("rsrq"));
            System.out.println("NeighborCells: "+row.getString("neighborcells")); 
            System.out.println("DetectedCells: "+row.getString("detectedcells")); 
            System.out.println("NeighborCellId: "+row.getString("neighborcellid")); 
            System.out.println("NeighborRSRP: "+row.getString("neighborrsrp")); 
            System.out.println("NeighborRSRQ: "+row.getString("neighborrsrq"));
            System.out.println("=========================================================");
            count++;
        }
        System.out.println("行数:"+count);//print line number
    }
    
    //查询GPS数据    //query for GPS data
        public void loadGPSData() {
            String select = "select* from gpsdata.gps";
            ResultSet resultSet = getSession().execute(select);
            int count=0;
            for (Row row : resultSet) {
                System.out.println("time: "+row.getString("time"));
                System.out.println("gps_time: "+row.getString("gps_time"));
                System.out.println("longitude: "+row.getString("longitude"));
                System.out.println("latitude: "+row.getString("latitude"));
                System.out.println("altitude: "+row.getString("altitude"));
                System.out.println("heading: "+row.getString("heading"));
                System.out.println("speed: "+row.getString("speed"));
                System.out.println("source: "+row.getString("source"));
                System.out.println("satellites: "+row.getString("satellites")); 
                System.out.println("=========================================================");
                count++;
            }
            System.out.println("行数:"+count);//print line number
        }
    
    public void close() {
        cluster.close();
        System.out.println("程序正常关闭！");// program normally shut down
    }
 
    public static void main(String[] args) {
        QueryAndUpdateData client = new QueryAndUpdateData();
        client.connect("127.0.0.1");
//        client.insertData("DB");
//        client.loadTAData();
        client.loadDBData();
//        client.loadGPSData();
        client.session.close();
        client.close();
    }
}