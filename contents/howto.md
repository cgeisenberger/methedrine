
This web application is designed for the diagnostic classification of Neuroendocrine Tumors (NETs) using array-based
DNA methylation data. This includes determining the tissue of origin and generation of a genomic copy-number profile. The details concerning the training, performance and purpose of the classifier are outlined in the accompanying publication by [*Hackeng et al., 2020*](https://www.google.com).

> Note: Be aware that sample processing can take a while after pressing the submit button.
> Unless there are error messages, the server is probably still busy.


**Technical Notes**

NET-ID currently supports Illumina's **HumanMethylation450** ("450k") and **HumanMethylationEPIC** ("EPIC") platforms. Samples have to be supplied as **raw IDAT files**. Classification results (and additional information) are condensed into a **classification report** for each sample. The output file format (HTML or PDF) can be specified by the user. After supplying valid IDAT files via the upload form, the job has to be submitted to the server. Once all samples have been processed, the resulting reports are bundled into a zip file (*results.zip*) and made avaialble for download. Due to limitations in computational power, uploads are currently limited to a **maximum of ten cases**. If higher throughput is desired, users are suggested to either set up a local instance of the application or use the underlying R package directly. For more information, visit the github repositories of [*crystalmeth*](https://github.com/cgeisenberger/crystalmeth) and [*methedrine*](https://github.com/cgeisenberger/methedrine).

<br>

**Support**

If you should need help in running this tool or have questions regarding the software, please contact the authors [@cgeisenberger](https://github.com/cgeisenberger) and [@whackeng](https://github.com/whackeng).