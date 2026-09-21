package examples;
import java.util.ArrayList;

import java.util.List;
import java.io.*;
import java.util.Scanner;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

import javax.swing.plaf.basic.BasicInternalFrameTitlePane.SystemMenuBar;

import org.apache.log4j.xml.DOMConfigurator;
import org.json.*;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;

import fr.cnes.los.stela.tle.business.implementation.TwoLineElementsRes;
import fr.cnes.los.stela.tle.business.logic.TleException;
import fr.cnes.los.stela.tle.business.implementation.TwoLineElementsConverter; 
import fr.cnes.los.stela.tle.business.implementation.TwoLineElements; 
import fr.cnes.los.stela.commons.logic.date.DateTime;
import fr.cnes.los.stela.commons.logic.date.StelaDate;
import fr.cnes.los.stela.commons.logic.exception.CommonException;
import fr.cnes.los.stela.commons.logic.log.service.LoggerAgentFactory;
import fr.cnes.los.stela.commons.logic.log.service.LoggerException;
import fr.cnes.los.stela.commons.logic.message.CommonMessage;
import fr.cnes.los.stela.commons.model.AdvancedParameters;
import fr.cnes.los.stela.commons.model.DefaultValues;
import fr.cnes.los.stela.commons.model.Prop;
import fr.cnes.los.stela.commons.model.ShortPeriodsSettings;
import fr.cnes.los.stela.commons.model.SpacecraftType;
import fr.cnes.los.stela.commons.model.atmosmodel.IAtmosphericModel;
import fr.cnes.los.stela.commons.model.dragcoeff.IDragCoef;
import fr.cnes.los.stela.commons.model.ephemeris.Bulletin;
import fr.cnes.los.stela.commons.model.ephemeris.FrameTypes;
import fr.cnes.los.stela.commons.model.ephemeris.NatureTypes;
import fr.cnes.los.stela.commons.model.ephemeris.SimulationType;
import fr.cnes.los.stela.commons.model.ephemeris.type.Type0PosVel;
import fr.cnes.los.stela.commons.model.ephemeris.type.Type1PosVel;
import fr.cnes.los.stela.commons.model.ephemeris.type.Type2PosVel;
import fr.cnes.los.stela.commons.model.ephemeris.type.Type8PosVel;
import fr.cnes.los.stela.commons.model.solaractivity.ISolarActivity;
import fr.cnes.los.stela.commons.model.spaceobject.ISpaceObject;
import fr.cnes.los.stela.commons.model.spaceobject.SpaceObject;
import fr.cnes.los.stela.commons.model.thirdbody.IThirdBody;
import fr.cnes.los.stela.elib.business.framework.ephemeris.model.EphemerisManager;
import fr.cnes.los.stela.elib.business.framework.simulation.IExtrapolationFeedback;
import fr.cnes.los.stela.elib.business.implementation.atmosmodel.msis00.MSIS00Adapter;
import fr.cnes.los.stela.elib.business.implementation.atmosphericdrag.AtmosphericDragAcc;
import fr.cnes.los.stela.elib.business.implementation.converter.BulletinNatureConverter;
import fr.cnes.los.stela.elib.business.implementation.diffeq.DiffEq;
import fr.cnes.los.stela.elib.business.implementation.diffeq.IForceModel;
import fr.cnes.los.stela.elib.business.implementation.dragcoef.constant.model.ConstantDragCoef;
import fr.cnes.los.stela.elib.business.implementation.dragcoef.variable.model.VariableDragCoef;
import fr.cnes.los.stela.elib.business.implementation.earthpotential.tesseral.TesseralAcc;
import fr.cnes.los.stela.elib.business.implementation.earthpotential.zonal.ZonalAcc;
import fr.cnes.los.stela.elib.business.implementation.integrator.Integrator;
import fr.cnes.los.stela.elib.business.implementation.noninertial.ApparentAcc;
import fr.cnes.los.stela.elib.business.implementation.solaractivity.constantmodel.ConstantSolarActivity;
import fr.cnes.los.stela.elib.business.implementation.solaractivity.variablemodel.VariableSolarActivity;
import fr.cnes.los.stela.elib.business.implementation.solarradiationpressure.SRPAcc;
import fr.cnes.los.stela.elib.business.implementation.thirdbody.ThirdBodyAcc;
import fr.cnes.los.stela.elib.business.implementation.thirdbody.moon.model.MoonOrbit;
import fr.cnes.los.stela.elib.business.implementation.thirdbody.sun.model.SunOrbit;
import fr.cnes.los.stela.elib.business.implementation.tide.SolidTidesAcc;
import fr.cnes.los.stela.elib.business.logic.ElibException;
import fr.cnes.los.stela.etoo.business.framework.simulation.SimulationManager;
import fr.cnes.los.stela.etoo.business.implementation.simulation.leosimulation.LEOSimulation;
import fr.cnes.los.stela.etoo.business.implementation.simulation.gtosimulation.GTOSimulation;
import fr.cnes.los.stela.processing.logic.exception.ProcessingException;
public class Test {
	
	public static void main(final String[] args) throws CommonException, ElibException, ProcessingException, IOException, InterruptedException, ParseException {

        // ===================== INITIALIZATION ROOT DIRECTORY =====================

        // Set root directory: this is mandatory (default root directory is your working directory)
        Prop.defineROOT("C:\\Users\\ruthn\\STELA"); // Replace value by the path where you set up STELA

        // Other file definitions (optional):
        // Prop allows you to define several files with a relative path (referring to ROOT) or absolute path
        // Example 1: Prop.setStelaSolarActivity("mySolarActivityFile.txt"); // Solar activity file is Prop.ROOT + mySolarActivityFile.txt
        // Example 2: Prop.setStelaSolarActivity("C:\Documents\STELA\mySolarActivityFile.txt"); // Solar activity file is C:\Documents\STELA\mySolarActivityFile.txt
        
        // ============================== INITIALIZATION LOGGER ==============================

        System.out.println("Start STELA library mode!");

        // Configure a basic console logger for log4j that will show everything logged

        // Get file in stela_console_log4j.xml in stela-commons-X.X.X.jar archive
        // Add the file in resource folder of your project
        // Modify level info as   
        //        <root>
        //            <level value="info" />
        //            <!-- During development, replace null by console -->
        //            <appender-ref ref="console" />
        //        </root>
        DOMConfigurator.configure(ClassLoader.getSystemResource("stela_console_log4j.xml"));

        // ===================== INITIALIZATION LANGUAGE =====================
        // Set language: this is optionnal (default language is english)
        Prop.defineLANG("en");

        try {
            LoggerAgentFactory.getLoggerAgent().init("stela_service_log_config.xml");
            LoggerAgentFactory.getLoggerAgent().newLogger("StelaMainLog");
        } catch (final LoggerException e) {
            System.err.println("Error during initialize logger");
            System.exit(2);
        }

        final fr.cnes.los.stela.commons.logic.log.service.Logger logger = LoggerAgentFactory.getLoggerAgent().getDefaultLogger();

        logger.log(CommonMessage.initialization());
        
        //Convert from TLE
        //initiate simulation
        //Save numbers from each integration
        //write out to a text file??
        

        // ============================== LAUNCH SIMULATION ==============================
        try {
			simpleLEOPropagation();
		} catch (ElibException | ProcessingException | CommonException | TleException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        
        System.out.println("End STELA library mode!");
    }
	
	private static void simpleLEOPropagation() throws ElibException, ProcessingException, CommonException, TleException, IOException, InterruptedException, ParseException {
        // Initial date (TAI scale)
        final StelaDate initialDate = new StelaDate(DateTime.parseDate("2024-10-01T24:00:00.000"));
        
        //TwoLineElementsConverter convertToMean = TwoLineElementsConverter.getInstance();
        //TwoLineElementsRes res = convertToMean.convertToMean(null, null);
        FileWriter params = new FileWriter("C:\\Users\\ruthn\\OneDrive\\Documents\\Masters at York\\params.txt");
        params.write("N \t Inclination \t Raan \t Aop \t MA \t MM \t e \t SMA \t Mass \t Diameter \n");
        File file = new File("C:\\Users\\ruthn\\OneDrive\\Documents\\Masters at York\\TLE copy\\TLE copy\\TLE-Master.txt");
        Scanner sc = new Scanner(file);
        int sats = 0;
        while (sats < 1000 && sc.hasNextLine()) {
	        String line1 = sc.nextLine();
	        
	        System.out.print(sats+"\n");
	        
	        String string1 = sc.nextLine();
	        String string2 = sc.nextLine();
	        if (!(line1.equals("0 TBA - TO BE ASSIGNED"))) {       
	        	TwoLineElements Tle = new TwoLineElements(string1, string2);
	        	double i = Tle.getInclination(); // inclination
		        double raan = Tle.getRightAscension(); // right ascension of ascending node
		        double aop = Tle.getArgPerigee(); // argument of periapsis
		        double mu       = 3.986004418e+14;
		        double rE = 6.378e+6;
		        double M = Tle.getMeanAnomaly(); // mean anomaly
		        double MM = Tle.getMeanMotion();
		        double e = Tle.getEccentricity();
		        String name = Tle.getInternationalDesignator();
		        
		        double sma = Math.cbrt(mu/(Math.pow((MM*2*Math.PI/86400), 2)));
		        System.out.println(sma-rE);
		        //sma = sma/1000;
		        if (sma-rE < 400000 && sma-rE > 200000) {
		        	
		        	if (sats>=0) {
			         double za = sma*(1+e) - rE; // apogee altitude
			        double zp = sma*(1-e) - rE; // perigee altitude 
			     
			        Type0PosVel initialOrbit = new Type0PosVel(zp, za, i, aop, raan, M, NatureTypes.OSCULATING, FrameTypes.ICRF);
			       
			        Bulletin initialState = new Bulletin(initialDate, initialOrbit);
			
			        // Spacecraft
			        double mass = 250;
			        
			        double dragArea = 0.2; // m2
			        try {
			        HttpClient client = HttpClient.newHttpClient();
			        
			        String url = "https://discosweb.esoc.esa.int/api/objects?filter=eq(satno,"+Tle.getSatId()+")";
			        String token = "ImMwNzBmZTdiLWIyZmMtNDNhOS05YjM4LTIzMzc1NjI5NmE4ZiI.jnVD8J_iVXBt0fNQOZzsk40m9UY";
			
			        HttpRequest request = HttpRequest.newBuilder()
			        .uri(URI.create(url))
			        .header("Authorization", "Bearer "+token) 
			        .GET()
			        .build();
			
			        HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
			        
			        JSONParser parse = new JSONParser(); 
			        JSONObject response_JSON = (JSONObject) parse.parse(response.body());
			        
			        //System.out.println();
			        
			        String temp = (response_JSON.get("data")).toString();
			        JSONObject data = (JSONObject)((JSONArray) parse.parse(temp)).get(0);
			        JSONObject attributes = (JSONObject) parse.parse(data.get("attributes").toString());
			        
			        
			        
			        if (attributes.get("mass") != null)
			        {
			        	mass = (double) attributes.get("mass");
			        }
			        
			        
			        if (attributes.get("diameter") != null)
			        {
			        	dragArea = (double) attributes.get("diameter");
			        	dragArea *= dragArea;
			        }
			        System.out.println("Response Body: " + dragArea);
			        } catch (Exception ex) {
			        	
			        }
			        
			        params.write(name + sats+ "\t" + i + "\t" + raan + "\t" + aop + "\t" + M + "\t" + MM + "\t" + e + "\t" + sma + "\t" + mass + "\t" +  dragArea + "\n");
			        
			        double reflectivityArea = 10.; // m2
			        double reflectivityCoef = 1.5;
			        IDragCoef dragCoef = new VariableDragCoef();
			        ISpaceObject spaceObject = new SpaceObject("My spacecraft", mass, dragArea, reflectivityArea, reflectivityCoef, dragCoef);
			
			        // Simulation initialization
			        double simulationDuration = 0.0000571; // Years
			        double missionDuration = 1;
			        ISolarActivity solarActivity = new VariableSolarActivity();
			        IAtmosphericModel atmosModel = new MSIS00Adapter();
			        EphemerisManager ephManager = new EphemerisManager(initialState);
			        
			        double integrationStep = 10; // s
			        double ephStep = 10; // s (should be a multiple of the integration step)
			        int dragQuadPoints = 33;
			        int srpQuadPoints = 11;
			        int atmosDragRecomputeStep = 1;
			        boolean dragSwitch = true;
			        boolean sunSwitch = true;
			        boolean moonSwitch = true;
			        boolean srpSwitch = true;
			        boolean zonalSwitch = true;
			        boolean tesseralSwitch = true;
			        boolean solidTidesSwitch = true;
			        double ttMinusUT1 = 68.184;
			        double reentryAltitude = 85000; // m
			        double nbIntegrationStepTesseral = 5.;
			        int tesseralOrder = 7;
			        int zonalOrder = 7;
			
			        LEOSimulation leoSim = new LEOSimulation("Default Author", "Propagation example", spaceObject, simulationDuration, null, missionDuration, ephManager,
			                ephStep, integrationStep, ttMinusUT1, reentryAltitude, zonalSwitch, zonalOrder, tesseralSwitch, tesseralOrder,
			                nbIntegrationStepTesseral, sunSwitch, moonSwitch, dragSwitch, atmosModel, solarActivity, dragQuadPoints, atmosDragRecomputeStep,
			                srpSwitch, srpQuadPoints, solidTidesSwitch, 10, 10, 10, null);
			
			        boolean extrapolationStatus = leoSim.simulate(null);
			       
			
			        // Get ephemeris
			        ArrayList<Bulletin> ephemeris = ephManager.getEphemerisList();
			
			        // Get the parameters of the orbit at the end of the propagation
			        Bulletin finalState = ephemeris.get(ephemeris.size() - 1);
			        //System.out.print(ephemeris.toString());
			        System.out.print("Eph size: "+ephemeris.size()+"\n");
			        // The final orbit parameters can be retrieved in type 8
			        Type8PosVel finalOrbitType8 = (Type8PosVel) finalState.getPosVel();
			        // Convert the final orbit into a Keplerian orbit
			        Type2PosVel finalOrbitType2 = finalOrbitType8.toType2();
			    
			        
			        //File fout = new File("C:\\\\Users\\\\ruthn\\\\OneDrive\\\\Documents\\\\Masters at York\\out.mat");
			        FileWriter fw = new FileWriter("C:\\Users\\ruthn\\OneDrive\\Documents\\Masters at York\\"+sats+".txt");
			        
			        for (int j = 0; j < ephemeris.size(); j++) 
			        {	
			        	Bulletin state = ephemeris.get(j);
			        	Type8PosVel state_8 = (Type8PosVel) state.getPosVel();
			        	Type1PosVel state_cart = state_8.toType1();
			        	fw.write(state.getDate()+"\t"+state_cart.getRowInformation()+"\n");
			        }
			        fw.close();
			        sats++;
		        	}
				        
			    }
			       
		        											
	        }
        
        }
        params.close();
    }

}
