#include "TString.h"
#include "TFile.h"
#include "TTree.h"
#include "TRandom3.h"

#include <fstream>
#include <iostream>

using namespace std;


//void LUND_tagged(int fileNum,TString prefix);

//void LUND_tagged(int iFile, TString prefix);


/*void LUND_genQESuite(int nFiles = 300, TString prefix = "") {

  for(int i = 1; i < nFiles+1; i++) 
    {
      LUND_tagged(i,prefix);
      cout << i <<endl;
    }
}
*/

void LUND_fromGENIE_rootracker_C()
{
  ifstream carbon_6GeV_filelist("carbon_6GeV_rootracker.list");

  for (int ii = 0; ii<199; ii++)
    {
      TString filename;
      carbon_6GeV_filelist >> filename; 

      TFile* inFile = new TFile(filename);
      TString lundPath = "../lundfiles/";
      
      int nFiles =  1;
      
      TTree* T = (TTree*)inFile->Get("gRooTracker");
      
      //	double targetMin = -2.75;	// cm
      //	double targetMax = -2.25;
      double rasterX = 0.04;	// cm
      double rasterY = 0.04; 	// cm
      
      double mass_e = 0.511e-3;
      double mass_p = 0.938272;	
      double mass_n = 0.93957;
      double mass_pi = 0.13957;
      
      int targA = 12;
      int targZ = 6;
      double targP = 0.; // polarization
      double beamP = 0.; // polarization
      int interactN = 1; 
      int beamType = 11;
      
      double beamE = -99;	// GeV
      TRandom3 *myRand = new TRandom3(0);
      
      Bool_t          qel;
      Bool_t          mec;
      Bool_t          res;
      Bool_t          dis;
      //will be coded into 1,2,3,4
      
      //final state particles 
      Int_t           nf;
      Int_t           pdgf[125];   //[nf]                                   
      Double_t        Ef[125];   //[nf]                                  
      Double_t        pxf[125];   //[nf]                                    
      Double_t        pyf[125];   //[nf]                                    
      Double_t        pzf[125];   //[nf]    
      //electron info
      Double_t        El;
      Double_t        pxl;
      Double_t        pyl;
      Double_t        pzl;
      
      T->SetBranchAddress("qel", &qel);
      T->SetBranchAddress("mec", &mec);
      T->SetBranchAddress("res", &res);
      T->SetBranchAddress("dis", &dis);
      
      T->SetBranchAddress("pdgf", pdgf);
      T->SetBranchAddress("nf", &nf);
      T->SetBranchAddress("Ef", Ef);
      T->SetBranchAddress("pxf", pxf);
      T->SetBranchAddress("pyf", pyf);
      T->SetBranchAddress("pzf", pzf);
      
      T->SetBranchAddress("El", &El);
      T->SetBranchAddress("pxl", &pxl);
      T->SetBranchAddress("pyl", &pyl);
      T->SetBranchAddress("pzl", &pzl);
      
      int nEvents = T->GetEntries();
      cout<<"Number of events "<<nEvents<<endl;
      
      TString formatstring, outstring;
      
      //Check the number of files is not more than what is in the file 
      //if( nFiles  > nEvents/10000)
      //nFiles = nEvents/10000;
      
      //Split large GENIE output into 10000 lund files
      //for (int iFiles = 1; iFiles < nFiles; iFiles++)
      //{
	  
      TString outfilename = Form("%s/lund_GENIE_C_6GeV_Q2_0_6_Rad_%d.dat",lundPath.Data(),iFiles);	//
      ofstream outfile;
      outfile.open(outfilename); 
	  //int start = (iFiles-1)*10000;
	  //int end   = iFiles*10000;
	  
	  for (int i = 0; i < nEvents; i++)
	    {
	      T->GetEntry(i);
	      
	      double code = 0;
	      //qel = 1, mec = 2, rec = 3, dis=4

	      if(qel)
		code = 1;
	      else if(mec)
		code = 2;
	      else if(res)
		code = 3;
	      else if(dis)
		code = 4;

	      if(code < .01)
		continue;
	      
	      int nf_mod = 1;
	      for(int iPart = 0; iPart < nf; iPart++)
		{
		  if(pdgf[iPart] == 2212)
		    nf_mod++;
		  else if(pdgf[iPart] == 2112)
		    nf_mod++;
		  else if(pdgf[iPart] == 211)
		    nf_mod++;
		  else if(pdgf[iPart] == -211)
		    nf_mod++;
		}
	    
	      // LUND header for the event:
	      formatstring = "%i \t %i \t %i \t %.3f \t %.3f \t %i \t %.1f \t %i \t %i \t %.3f \n";
	      outstring = Form(formatstring, nf_mod, targA, targZ, targP, beamP, beamType, beamE, interactN, i, code);
	      
	      outfile << outstring; 
	      
	      double upstream_foil = -4.2; //cm
	      double target_spacing = 1.25; //com
	      double vx = myRand->Uniform(-rasterX/2., rasterX/2.);	
	      double vy = myRand->Uniform(-rasterY/2., rasterY/2.);
	      
	      double vz = upstream_foil + (myRand->Integer(4)*target_spacing);

	      // LUND info for each particle in the event
		  
	      formatstring = "%i \t %.3f \t %i \t %i \t %i \t %i \t %.5f \t %.5f \t %.5f \t %.5f \t %.5f \t %.5f \t %.5f \t %.5f \n";

	      int part_num = 0;

	      //electron
	      outstring = Form(formatstring, 1, 0.0, 1, 11, 0, 0, pxl, pyl, pzl, El, mass_e, vx, vy, vz);  
	      outfile << outstring;
	      part_num++;
	    
	      for(int iPart = 0; iPart < nf; iPart++)
		{
		  if(pdgf[iPart] == 2212)
		    {//p
		      part_num++;

		      outstring = Form(formatstring, part_num, 0.0, 1, pdgf[iPart], 0, 0, pxf[iPart], pyf[iPart], pzf[iPart], Ef[iPart], mass_p, vx, vy, vz);
		      outfile << outstring;
		    }
		  else if(pdgf[iPart] == 2112)
		    {//n
		      part_num++;
		      outstring = Form(formatstring, part_num, 0.0, 1, pdgf[iPart], 0, 0, pxf[iPart], pyf[iPart], pzf[iPart], Ef[iPart], mass_n, vx, vy, vz);
		      outfile << outstring;
		    }
		  else if(pdgf[iPart] == 211)
		    {
		      part_num++;
		      outstring = Form(formatstring, part_num, 0.0, 1, pdgf[iPart], 0, 0, pxf[iPart], pyf[iPart], pzf[iPart], Ef[iPart], mass_pi, vx, vy, vz);
		      outfile << outstring;
		    }
		  else if(pdgf[iPart] == -211)
		    {
		      part_num++;
		      outstring = Form(formatstring, part_num, 0.0, 1, pdgf[iPart], 0, 0, pxf[iPart], pyf[iPart], pzf[iPart], Ef[iPart], mass_pi, vx, vy, vz);
		      outfile << outstring;
		    }
		  
		}
	      
	    }
	  
	  outfile.close();
	  
	  //}
    }
}
