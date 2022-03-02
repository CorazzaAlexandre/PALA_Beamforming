### PALA Delay-and-Sum beamforming

We provide an easy beamforming code to reconstruct radiofrequency data (RF) provided in the dataset. This beamformer was NOT used for this study and was NOT included in the review process.
It can help to understand RF data to compare various beamforming technics used for Ultrasound Localization Microscopy.

This code was written by Alexandre Corazza, 13/10/2021, and adapted by Arthur Chavignon 03/03/2022.

The Delay-and-Sum algorithm was inspired from the function `dasmtx.m` of _MUST_ (Matlab UltraSound Toolbox) [www.biomecardio.com](https://www.biomecardio.com/MUST) by Damien Garcia.
Reference on DAS beamforming: [*So you think you can DAS? A viewpoint on delay-and-sum beamforming*, Ultrasonics, 2021](https://doi.org/10.1016/j.ultras.2020.106309).

#### 1. WARNING
Beamformed images may be worse than those provided by Verasonics Vantage beamformer.
All results and scores of the article have been computed on images provided by Vantage beamforming. Computing metrics on this homemade beamformer may result in biased scores.

#### 2. RELATED DATASET
Simulated and in vivo datasets are available on Zenodo [10.5281/zenodo.4343435](https://doi.org/10.5281/zenodo.4343435).
RF data are available for `PALA_data_InSilicoFlow` and `PALA_data_InSilicoPSF` datasets.

#### 3. PATH AND LOCATIONS
This folder must be used with the PALA toolbox https://github.com/AChavignon/PALA/tree/master/PALA.
It must be placed in `/PALA/PALA_Beamforming`.
Before running scripts, two paths are required and have to be set in `PALA_SetUpPaths.m` to your computer environment:
- `PALA_addons_folder`: the addons folder with all dedicated functions for PALA
- `PALA_data_folder`: root path of your data folder

#### 4. ACADEMIC REFERENCES TO BE CITED
Details of the code in the article by Heiles, Chavignon, Hingot, Lopez, Teston and Couture.  
[*Performance benchmarking of microbubble-localization algorithms for ultrasound localization microscopy*, Nature Biomedical Engineering, 2022 (10.1038/s41551-021-00824-8)](https://www.nature.com/articles/s41551-021-00824-8).

General description of super-resolution in: Couture et al., [*Ultrasound localization microscopy and super-resolution: A state of the art*, IEEE UFFC 2018](https://doi.org/10.1109/TUFFC.2018.2850811).

#### 5. DISCLAIMER
THIS SOFTWARE IS PROVIDED BY THE AUTHORS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHORS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
