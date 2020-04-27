---
title: "Small Workflow Example"
chapter: false
weight: 10
---

## Local Run

Nextflow allows the execution of any command or user script by using a process definition.

A process is defined by providing three main declarations: the process [inputs](https://www.nextflow.io/docs/latest/process.html#inputs), the process [outputs](https://www.nextflow.io/docs/latest/process.html#outputs) and finally the command [script](https://www.nextflow.io/docs/latest/process.html#script).

The example workflow implements a simple RNA-seq pipeline which:

   1. Indexes a trascriptome file.
   2. performs quality controls
   3. performs quantification
   4. creates a MultiQC report

### Nextflow DSL

Even though this is not a deep dive into Nextflow's DSL - please have a look at how the Nextflow script is structured and appreciate the UNIX resemblance having an `input`, `output` and a `script`.
You can dive deeper by going through the [Nextflow documentation](https://www.nextflow.io/docs/latest/getstarted.html) and tutorials ([nextflow-camp tutorial](https://github.com/nextflow-io/nfcamp-tutorial), [DSL-2](https://www.nextflow.io/docs/edge/dsl2.html)).

```ruby
/* 
 * pipeline input parameters 
 */
params.reads = "$baseDir/data/ggal/gut_{1,2}.fq"
params.transcript = "$baseDir/data/ggal/transcriptome.fa"
params.multiqc = "$baseDir/multiqc"
params.outdir = "results"

log.info """\
         R N A S E Q - N F   P I P E L I N E    
         ===================================
         transcriptome: ${params.transcript}
         reads        : ${params.reads}
         outdir       : ${params.outdir}
         """
         .stripIndent()

 
/* 
 * define the `index` process that create a binary index 
 * given the transcriptome file
 */
process index {
    
    input:
    path transcriptome from params.transcript
     
    output:
    path 'index' into index_ch

    script:       
    """
    salmon index --threads $task.cpus -t $transcriptome -i index
    """
}
```

### Pull Image and run

As nextflow will run the image `nextflow/rnaseq-nf` and thus needs to download almost 3GB without advancing, we will first download the image so that we can see what docker is doing.

```bash
docker pull nextflow/rnaseq-nf
```

Outut will look like this:

```bash
$ docker pull nextflow/rnaseq-nf
Using default tag: latest
latest: Pulling from nextflow/rnaseq-nf
b8f262c62ec6: Pull complete
fa9712f20293: Pull complete
6ec1e76960c6: Pull complete
fe231f126300: Pull complete
b5060e108b58: Pull complete
ba0e69f9489f: Pull complete
248da7e19707: Pull complete
Digest: sha256:0ac11ff903d39ad7db18e63c8958fb11864192840b3d9ece823007a54f3703e0
Status: Downloaded newer image for nextflow/rnaseq-nf:latest
```

Afterwards we can start the script, which will subsequently start a container using the just pulled image.

```bash
nextflow run script7.nf --reads 'data/ggal/*_{1,2}.fq'
```

The output will look like this.

```bash
$ nextflow run script7.nf --reads 'data/ggal/*_{1,2}.fq'
N E X T F L O W  ~  version 20.01.0
Launching `script7.nf` [admiring_edison] - revision: ce58523d1d
R N A S E Q - N F   P I P E L I N E
===================================
transcriptome: /home/ec2-user/environment/nextflow-tutorial/data/ggal/transcriptome.fa
reads        : data/ggal/*_{1,2}.fq
outdir       : results
executor >  local (8)
[62/dfabf8] process > index          [100%] 1 of 1 ✔
[c7/aa994c] process > quantification [100%] 3 of 3 ✔
[86/c377f4] process > fastqc         [100%] 3 of 3 ✔
[08/3c2c49] process > multiqc        [100%] 1 of 1 ✔
Done! Open the following report in your browser --> results/multiqc_report.html
$
```

The report can be previewed within Cloud9. Right-click (**[1]**) on the file and choose `Preview` (**[2]**) from the context menue.

![multiqc_report](/images/nextflow-on-aws-batch/nextflow101/multiqc_report.png)