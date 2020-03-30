**Introduction**

This web application is designed for the diagnostic classification of Neuroendocrine Tumors (NETs) using array-based
DNA methylation data. This includes determining the tissue of origin, tumor purity inference and generation of a genomic copy-number profile. Details concerning the classification algorithm are outlined in the accompanying publication by *Hackeng et al.* (manuscript in preparation).

> Note: Be aware that sample processing can take a while after pressing the submit button.
> Unless there are error messages, the server is probably still busy.


**Technical Notes**

NET-ID currently supports Illumina's **HumanMethylation450** ("450k") and **HumanMethylationEPIC** ("EPIC") platforms. Samples have to be supplied as **raw IDAT files**. After completion of the upload and input file checks, the **submit button** is enabled and the job can be sent for processing by the user. Results for each sample are summarised as a one-page **classification report**, and its file format (PDF or HTML) can be specified by the user. Once all cases have been processed, the resulting **reports are bundled into a zip file** (results.zip) which is made available for download. Due to limitations in computational power, uploads will be limited to a **maximum of ten cases**. In case higher throughput is desired, users are suggested to either set up a local instance of the application or use the underlying R package directly. For more information, visit the github repositories of [*crystalmeth*](https://github.com/cgeisenberger/crystalmeth) and [*methedrine*](https://github.com/cgeisenberger/methedrine).


<br>

**Testing**

In case users would like to try the software, data and example reports for one test sample (450k) can be downloaded [here](https://www.dropbox.com/s/l3ixie4hysqm55b/netid_test_450k.zip?dl=0). 


<br>

**Support**

If you should need help in running this tool or have questions regarding the software, please contact the authors [@cgeisenberger](https://github.com/cgeisenberger) and [@whackeng](https://github.com/whackeng).


<br>

**Disclaimer**

NetID is not an official diagnostic tool. Classification using methylation profiling is a research application under development, it is not verified and has not been clinically validated. Implementation of the results in a clinical setting is in the sole responsibility of the treating physician. Intended for non-commercial use only.

