**Feedback and Support**

NEN-ID application was made possible through the support of many people. We would like to **encourage users to contact us** at *nenid.contact [at] gmail.com*. Tracking usage in this fashion allows us (1) to justify the monetary expenses, (2) contact users if changes are made to the software and (3) try to connect with the community interested in neuroendocrine neoplasms. This is optional and not reauired for usage, and any information such as email adresses will be treated with utmost care and not be shared with third parties. 

If you should need help in running this tool or have questions regarding the software, please use the email provided above or contact the authors [@cgeisenberger](https://github.com/cgeisenberger) and [@whackeng](https://github.com/whackeng).


**Introduction**

This web application uses bioinformatic and machine learning methods to analyze **array-based DNA methylation data**. It is specifically designed
for *Neuroendocrine Neoplasms* (NENs). Among others, the software can determine the **tissue of origin**, infer **tumor purity** and generate a genomic 
**copy-number profile**. Details concerning the classification algorithm are outlined in the accompanying publication (*Hackeng et al., Clinical Cancer Research, 2020 [manuscript provisionally accepted]*). 


**Quick How To**

1. Upload IDAT files via field on left hand side
2. `Submit button` is activated after succesful file transfer
3. Press `Submit Button` to start processing of samples
4. Wait for processing to finish (application displays progress bar)
5. One html report is rendered for each samples
6. Reports are bundled into zip file
7. Zip file is made available for download after succesful processing


**Technical Notes**

* Platforms: Illumina **HumanMethylation450** (*450k*) and **HumanMethylationEPIC** (*EPIC*)
* Input format: only **raw IDAT files**
* Maximum no. of cases: 10 (see below for more information)

Due to large demands in memory and computational power, uploads are currently limited to a **maximum of ten cases**. In case higher throughput is desired, users are suggested to either set up a local instance of the application or use the underlying R package directly. For more information, visit the github repositories of [*crystalmeth*](https://github.com/cgeisenberger/crystalmeth) and [*methedrine*](https://github.com/cgeisenberger/methedrine). Contact the authors if help is required (see Section *Support* for more information).


**Test Data**

In case users would like to try the software, data and example reports for one test sample (450k) can be downloaded [here](https://www.dropbox.com/s/xwn0c16wcarzjxv/nenid_test_data.zip?dl=0) (right click -> 'save link as'). 


**Disclaimer**

NetID is not an official diagnostic tool. Classification using methylation profiling is a research application under development, it is not verified and has not been clinically validated. Implementation of the results in a clinical setting is in the sole responsibility of the treating physician. Intended for non-commercial use only.

