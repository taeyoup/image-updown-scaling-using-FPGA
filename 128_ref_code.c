#include <stdio.h>
#include <stdlib.h>
#include <math.h>


int main()
{
	///////////////////////////////////////////////////////////////////////////////
	// open original bmp file
	///////////////////////////////////////////////////////////////////////////////

	FILE* fp_lenna_original;
	fopen_s(&fp_lenna_original, "D:\\lenna\\lenna_256.bmp", "rb");

	unsigned char header_info_lenna_original[54];
	fread(header_info_lenna_original, sizeof(unsigned char), 54, fp_lenna_original);

	unsigned int header_start_addr;
	unsigned int header_width_original;
	unsigned int header_height_original;

	header_start_addr = *(unsigned int*)&header_info_lenna_original[10];
	header_width_original = *(unsigned int*)&header_info_lenna_original[18];
	header_height_original = *(unsigned int*)&header_info_lenna_original[22];

	// let's check data
	// header_start_address should be "54"
	// header_width_original should be "256"
	// header_height_original should be "256"
	printf("header_start_addr: %u\n", header_start_addr);
	printf("header_width_original: %u\n", header_width_original);
	printf("header_height_original: %u\n", header_height_original);

	unsigned int size_lenna_original;
	size_lenna_original = 3 * header_width_original * header_height_original;

	// load pixel data
	unsigned char* data_lenna_original = (char*)malloc(sizeof(unsigned char) * size_lenna_original);

	//fseek(fp_lenna_original, 54, SEEK_SET);
	fread(data_lenna_original, sizeof(unsigned char), size_lenna_original, fp_lenna_original);

	printf("lenna[0][0][0] = %u\n", data_lenna_original[0]);
	printf("lenna[0][0][1] = %u\n", data_lenna_original[1]);
	printf("lenna[0][0][2] = %u\n", data_lenna_original[2]);

	///////////////////////////////////////////////////////////////////////////////
	// lenna_256.coe memory file gen.
	///////////////////////////////////////////////////////////////////////////////
	FILE* fp_lenna_coe;

	fopen_s(&fp_lenna_coe, "D:\\lenna\\lenna_256.coe", "wb");

	fprintf(fp_lenna_coe, "memory_initialization_radix = 16;\n");
	fprintf(fp_lenna_coe, "memory_initialization_vector=\n");
	unsigned char tmp_byte_data = 0;

	for (int row = 0; row < header_height_original; row++) {
		for (int col = 0; col < header_width_original; col++) {
			for (int channel = 2; channel >= 0; channel--) {
				tmp_byte_data = data_lenna_original[row * header_width_original * 3 + col * 3 + channel];
				if (tmp_byte_data < 16) {
					fprintf(fp_lenna_coe, "%x", 0);
				}
				fprintf(fp_lenna_coe, "%x", tmp_byte_data);
			}
			fprintf(fp_lenna_coe, ",\n");
		}
	}
	fseek(fp_lenna_coe, -2, SEEK_CUR);
	fprintf(fp_lenna_coe, ";");

	fclose(fp_lenna_coe);


	///////////////////////////////////////////////////////////////////////////////
	// do down-sample and write down-sampled bmp file
	///////////////////////////////////////////////////////////////////////////////

	FILE* fp_lenna_ds;
	fopen_s(&fp_lenna_ds, "D:\\lenna\\lenna_ds.bmp", "wb");

	// make lenna_ds's header info
	unsigned char header_info_lenna_ds[54];

	// copy lenna_256's header info
	for (int i = 0; i < 54; i++) {
		header_info_lenna_ds[i] = header_info_lenna_original[i];
	}

	// change width & height info
	unsigned int header_width_ds;
	unsigned int header_height_ds;
	header_width_ds = header_width_original / 2;
	header_height_ds = header_height_original / 2;
	*(unsigned int*)&header_info_lenna_ds[18] = header_width_ds;
	*(unsigned int*)&header_info_lenna_ds[22] = header_height_ds;

	// check whether lenna_ds's header info is changed correctly
	unsigned int test_tmp;
	test_tmp = *(unsigned int*)&header_info_lenna_ds[18];
	printf("ds_header_width: %u\n", test_tmp);
	test_tmp = *(unsigned int*)&header_info_lenna_ds[22];
	printf("ds_header_height: %u\n", test_tmp);

	// do simple down-sampling
	// in this example, we will just select(sample) one of the 4 pixels
	// you have to develop this part

	unsigned int size_lenna_ds;
	size_lenna_ds = 3 * header_width_ds * header_height_ds;

	unsigned char* data_lenna_ds = (char*)malloc(sizeof(unsigned char) * size_lenna_ds);

	int idx = 0;

	for (int row = 0; row < header_height_original; row++) {
		for (int col = 0; col < header_width_original; col++) {
			if ((row % 2) == 1) {
				break;
			}
			else {
				if ((col % 2) == 1) {

				}
				else {
					data_lenna_ds[idx + 0] = data_lenna_original[row * header_width_original * 3 + col * 3 + 0];
					data_lenna_ds[idx + 1] = data_lenna_original[row * header_width_original * 3 + col * 3 + 1];
					data_lenna_ds[idx + 2] = data_lenna_original[row * header_width_original * 3 + col * 3 + 2];

					idx = idx + 3;
				}
			}
		}
	}

	
	// write data
	fwrite(header_info_lenna_ds, sizeof(unsigned char), 54, fp_lenna_ds);
	fwrite(data_lenna_ds, sizeof(unsigned char), size_lenna_ds, fp_lenna_ds);

	///////////////////////////////////////////////////////////////////////////////
	// do up-sample and write up-sampled bmp file
	///////////////////////////////////////////////////////////////////////////////

	FILE* fp_lenna_us;
	fopen_s(&fp_lenna_us, "D:\\lenna\\lenna_us.bmp", "wb");

	// make lenna_ds's header info
	unsigned char header_info_lenna_us[54];

	// copy lenna_128's header info
	for (int i = 0; i < 54; i++) {
		header_info_lenna_us[i] = header_info_lenna_original[i];
	}

	// change width & height info
	unsigned int header_width_us;
	unsigned int header_height_us;
	header_width_us = header_width_original;
	header_height_us = header_height_original;


	// do simple up-sampling
	// in this example, we will just reproduct data
	// you have to develop this part
	unsigned int size_lenna_us;
	size_lenna_us = 3 * header_width_us * header_height_us;

	unsigned char* data_lenna_us = (char*)malloc(sizeof(unsigned char) * size_lenna_us);

	for (int row = 0; row < header_height_ds; row++) {
		for (int col = 0; col < header_width_ds; col++) {
			for (int k = 0; k < 3; k++) {
				if (row < header_height_ds - 1) {
					if (col < header_width_ds - 1) {
						data_lenna_us[row * 2 * header_width_us * 3 + col * 2 * 3 + k] = data_lenna_ds[row * header_width_ds * 3 + col * 3 + k];
						data_lenna_us[row * 2 * header_width_us * 3 + col * 2 * 3 + k + 3] = (data_lenna_ds[row * header_width_ds * 3 + col * 3 + k] + data_lenna_ds[row * header_width_ds * 3 + col * 3 + k + 3]) / 2;
						data_lenna_us[(row * 2 + 1) * header_width_us * 3 + col * 2 * 3 + k] = (data_lenna_ds[row * header_width_ds * 3 + col * 3 + k] + data_lenna_ds[(row + 1) * header_width_ds * 3 + col * 3 + k]) / 2;
						data_lenna_us[(row * 2 + 1) * header_width_us * 3 + col * 2 * 3 + k + 3] = (data_lenna_ds[row * header_width_ds * 3 + col * 3 + k] + data_lenna_ds[row * header_width_ds * 3 + col * 3 + k + 3] + data_lenna_ds[(row + 1) * header_width_ds * 3 + col * 3 + k] + data_lenna_ds[(row + 1) * header_width_ds * 3 + col * 3 + k + 3]) / 4;
					}
					else {
						data_lenna_us[row * 2 * header_width_us * 3 + col * 2 * 3 + k] = data_lenna_ds[(row)*header_width_ds * 3 + col * 3 + k];
						data_lenna_us[row * 2 * header_width_us * 3 + col * 2 * 3 + k + 3] = data_lenna_ds[row * header_width_ds * 3 + col * 3 + k];
						data_lenna_us[(row * 2 + 1) * header_width_us * 3 + col * 2 * 3 + k] = (data_lenna_ds[row * header_width_ds * 3 + col * 3 + k] + data_lenna_ds[(row + 1) * header_width_ds * 3 + col * 3 + k]) / 2;
						data_lenna_us[(row * 2 + 1) * header_width_us * 3 + col * 2 * 3 + k + 3] = (data_lenna_ds[row * header_width_ds * 3 + col * 3 + k] + data_lenna_ds[(row + 1) * header_width_ds * 3 + col * 3 + k]) / 2;
					}
				}
				else {
					if (col < header_width_ds - 1) {
						data_lenna_us[row * 2 * header_width_us * 3 + col * 2 * 3 + k] = data_lenna_ds[(row)*header_width_ds * 3 + col * 3 + k];
						data_lenna_us[row * 2 * header_width_us * 3 + col * 2 * 3 + k + 3] = (data_lenna_ds[row * header_width_ds * 3 + col * 3 + k] + data_lenna_ds[row * header_width_ds * 3 + col * 3 + k + 3]) / 2;
						data_lenna_us[(row * 2 + 1) * header_width_us * 3 + col * 2 * 3 + k] = data_lenna_ds[row * header_width_ds * 3 + col * 3 + k];
						data_lenna_us[(row * 2 + 1) * header_width_us * 3 + col * 2 * 3 + k + 3] = (data_lenna_ds[row * header_width_ds * 3 + col * 3 + k] + data_lenna_ds[row * header_width_ds * 3 + col * 3 + k + 3]) / 2;
					}
					else {
						data_lenna_us[row * 2 * header_width_us * 3 + col * 2 * 3 + k] = data_lenna_ds[(row)*header_width_ds * 3 + col * 3 + k];
						data_lenna_us[row * 2 * header_width_us * 3 + col * 2 * 3 + k + 3] = data_lenna_ds[row * header_width_ds * 3 + col * 3 + k];
						data_lenna_us[(row * 2 + 1) * header_width_us * 3 + col * 2 * 3 + k] = data_lenna_ds[row * header_width_ds * 3 + col * 3 + k];
						data_lenna_us[(row * 2 + 1) * header_width_us * 3 + col * 2 * 3 + k + 3] = data_lenna_ds[row * header_width_ds * 3 + col * 3 + k];
					}
				}
			}
		}
	}




	// write data
	fwrite(header_info_lenna_us, sizeof(unsigned char), 54, fp_lenna_us);

	fwrite(data_lenna_us, sizeof(unsigned char), size_lenna_us, fp_lenna_us);

	///////////////////////////////////////////////////////////////////////////////
	// calculate psnr
	///////////////////////////////////////////////////////////////////////////////

	double mse_tmp = 0;
	double mse = 0;
	double psnr = 0;
	int size = 3 * header_height_original * header_width_original;

	for (int i = 0; i < size; i++) {
		mse_tmp += pow(data_lenna_original[i] - data_lenna_us[i], 2);
	}
	mse = mse_tmp / size;

	psnr = 20 * log10(255) - 10 * log10(mse);
	printf("psnr: %lf\n", psnr);



	///////////////////////////////////////////////////////////////////////////////
	// free malloc & colse file
	///////////////////////////////////////////////////////////////////////////////


	free(data_lenna_us);
	free(data_lenna_ds);
	free(data_lenna_original);

	fclose(fp_lenna_us);
	fclose(fp_lenna_ds);
	fclose(fp_lenna_original);


}