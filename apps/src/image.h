// This is a demo code for using a SSD model to do detection.
// The code is modified from examples/cpp_classification/classification.cpp.
// Usage:
//    ssd_detect [FLAGS] model_file weights_file list_file
//
// where model_file is the .prototxt file defining the network architecture, and
// weights_file is the .caffemodel file containing the network parameters, and
// list_file contains a list of image files with the format as follows:
//    folder/img1.JPEG
//    folder/img2.JPEG
// list_file can also contain a list of video files with the format as follows:
//    folder/video1.mp4
//    folder/video2.mp4
//
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <algorithm>
#include <iomanip>
#include <iosfwd>
#include <memory>
#include <string>
#include <utility>
#include <vector>
#include <math.h>
#include <arm_neon.h>
#include <opencv2/opencv.hpp>
#include <dnndk/n2cube.h>
//#include <dnndk/transform.h>

#define INPUTNODE "layer0_conv"
#define CONF 0.5

using namespace std;
using namespace cv;
using namespace std::chrono;

typedef struct {
    int w;
    int h;
    int c;
    float *data;
} image;

float str2float(const string &str) {
    stringstream ss(str);
    float result;
    ss >> result;
    return result;
}
void detect(vector<vector<float>> &boxes, vector<float> result, int channel, int height, int weight, int num, int sh, int sw);
image load_image_cv(const cv::Mat& img);
image letterbox_image(image im, int w, int h);
void free_image(image m);

void get_output(int8_t* dpuOut, int sizeOut, float scale, int oc, int oh, int ow, vector<float>& result) {
    vector<int8_t> nums(sizeOut);
    memcpy(nums.data(), dpuOut, sizeOut);
    for(int a = 0; a < oc; ++a){
        for(int b = 0; b < oh; ++b){
            for(int c = 0; c < ow; ++c) {
                int offset = b * oc * ow + c * oc + a;
                result[a * oh * ow + b * ow + c] = nums[offset] * scale;
            }
        }
    }
}

void set_input_image(DPUTask* task, const Mat& img, vector<float> &mean, vector<float> &scale) {
    Mat img_copy;
    int height = dpuGetInputTensorHeight(task, INPUTNODE);
    int width = dpuGetInputTensorWidth(task, INPUTNODE);
    int8_t* data = dpuGetInputTensorAddress(task, INPUTNODE);
    resize(img, img_copy, cv::Size(width, height));

    for (int idx_h=0; idx_h<img_copy.rows; idx_h++) {
        for (int idx_w=0; idx_w<img_copy.cols; idx_w++) {
            for (int idx_c=0; idx_c<3; idx_c++) {
                data[idx_h*img_copy.cols*3+idx_w*3+idx_c] =
                        (char)(int)((img_copy.at<Vec3b>(idx_h, idx_w)[idx_c] - mean[idx_c]) * scale[idx_c]);
            }
        }
    }
}

//void pertreat(uint8_t* src, int8_t* dst, int size, const int pos) {
//	for(int i = 0; i < size; i+=16) {
//		// int8x16_t shf_pos = vdupq_n_s8((int8_t)pos);
//		uint8x16_t u8_src = vld1q_u8(src + i);
//		uint8x16_t u8_mid = vshrq_n_u8(u8_src, pos);
//		int8x16_t s8_dst = vreinterpretq_s8_u8(u8_mid);
//		vst1q_s8(dst+i, s8_dst);
//	}
//}

template <typename Dtype>
void print_file(Dtype* input, int size, string filename) {
    ofstream fout(filename);
    for (int i = 0 ; i < size; ++i)
        fout << input[i]/128.0 << endl;
    fout.close();
}

template <typename Dtype>
void print_file_as_dpu(const Dtype* input, int channels, int height, int width, string filename){
    ofstream write_out(filename);
    int n=0;
    for(int a = 0; a < height; ++a){
        for(int b = 0; b < width; ++b){
            for(int c = 0; c < channels; ++c){
                int offset = c*height*width + a*width + b;
                write_out << input[offset]  << "\n";
                n++;
            }
        }
    }
    write_out.close();
}

void set_input_img2(DPUTask* task, const char* nodename, int8_t* str){
    int size = dpuGetInputTensorSize(task, nodename);
    int8_t* data = dpuGetInputTensorAddress(task, nodename);
    memcpy(data, str, size);
}

void set_data(const Mat& img, int8_t* data) {

    int height = 512;
    int width = 256;
    int size = 512 * 256 * 3;

    image img_new = load_image_cv(img);
    image img_yolo = letterbox_image(img_new, width, height);
    vector<float> bb(size);
    for(int b = 0; b < height; ++b)
        for(int c = 0; c < width; ++c)
            for(int a = 0; a < 3; ++a)
                bb[b*width*3 + c*3 + a] = img_yolo.data[a*height*width + b*width + c];

    float scale = pow(2, 7);
    for(int i = 0; i < size; ++i) {
        data[i] = std::round(bb.data()[i]*scale);
        if(data[i] < 0) data[i] = 127;
    }
    free_image(img_new);
    free_image(img_yolo);
}

void set_input_image(DPUTask* task, const Mat& img, float* mean, const char* nodename) {
    Mat img_copy;
    int height = dpuGetInputTensorHeight(task, nodename);
    int width = dpuGetInputTensorWidth(task, nodename);
    int size = dpuGetInputTensorSize(task, nodename);
    int8_t* data = dpuGetInputTensorAddress(task, nodename);

//memset(data, 0x0, 128);

#define pred
#ifdef pred
    image img_new = load_image_cv(img);
    image img_yolo = letterbox_image(img_new, width, height);
//    print_file_as_dpu(img_yolo.data, 3, height, width, "input.data");

//	for(int i = 0; i < height*width; ++i) {
//		float temp = img_yolo.data[i];
//		img_yolo.data[i] = img_yolo.data[i+height*width*2];
//		img_yolo.data[i+height*width*2] = temp;
//	}

    vector<float> bb(size);
    for(int b = 0; b < height; ++b)
        for(int c = 0; c < width; ++c)
            for(int a = 0; a < 3; ++a)
                bb[b*width*3 + c*3 + a] = img_yolo.data[a*height*width + b*width + c];

//	_T(pertreat(img_yolo.data, img_fix.data(), size, -7));
    float scale = pow(2, 7);
    for(int i = 0; i < size; ++i) {
        data[i] = int(bb.data()[i]*scale);
        if(data[i] < 0) data[i] = 127;
    }
//    print_file(data, size, "input.data");
    free_image(img_new);
    free_image(img_yolo);
    //data[i] = (int8_t)(img_yolo.data[i]*scale);
//	_T(memcpy(data, img_fix.data(), size));
#else
    vector<int8_t> img_fix(size);
	_T(resize(img, img_copy, cv::Size(width, height)));
	//_T(pertreat(img_copy.data, img_fix.data(), size, 1));
	//ofstream img_save("img_crop.bin", ios::binary);
	//img_save.write((char*)img_copy.data, size);
	//img_save.close();
	float scale = pow(2, -2);
	for(int i = 0; i < size; ++i) {
//		img_fix[i] = std::round(img_copy.data[i]*scale);
        img_fix[i] = (int)(img_copy.data[i]*scale);
		if(img_fix[i] < 0) img_fix[i] = 127;
	}
	memcpy(data, img_fix.data(), size);

/*
	for(int i = 0; i < height*width; ++i) {
		int8_t temp = img_fix[i];
		img_fix[i] = img_fix[i+height*width*2];
		img_fix[i+height*width*2] = temp;
	}
*/
	//_T(memcpy(data, img_fix.data(), size));
#endif

}


inline float sigmoid(float p) {
    return 1.0 / (1 + exp(-p * 1.0));
}

inline float overlap(float x1, float w1, float x2, float w2) {
    float left = max(x1 - w1 / 2.0, x2 - w2 / 2.0);
    float right = min(x1 + w1 / 2.0, x2 + w2 / 2.0);
    return right - left;
}

inline float cal_iou(vector<float> box, vector<float>truth) {
    float w = overlap(box[0], box[2], truth[0], truth[2]);
    float h = overlap(box[1], box[3], truth[1], truth[3]);
    if(w < 0 || h < 0) return 0;
    float inter_area = w * h;
    float union_area = box[2] * box[3] + truth[2] * truth[3] - inter_area;
    return inter_area * 1.0 / union_area;
}

vector<vector<float>> apply_nms(vector<vector<float>>& boxes,int classes, const float thres) {
    vector<pair<int, float>> order(boxes.size());
    vector<vector<float>> result;
    for(int k = 0; k < classes; k++) {
        for (size_t i = 0; i < boxes.size(); ++i) {
            order[i].first = i;
            boxes[i][4] = k;
            order[i].second = boxes[i][6 + k];
        }
        sort(order.begin(), order.end(),
             [](const pair<int, float> &ls, const pair<int, float> &rs) { return ls.second > rs.second; });
        vector<bool> exist_box(boxes.size(), true);
        for (size_t _i = 0; _i < boxes.size(); ++_i) {
            size_t i = order[_i].first;
            if (!exist_box[i]) continue;
            if (boxes[i][6 + k] < CONF) {
                exist_box[i] = false;
                continue;
            }
            //add a box as result
            result.push_back(boxes[i]);
            //cout << "i = " << i<<" _i : "<< _i << endl;
            for (size_t _j = _i + 1; _j < boxes.size(); ++_j) {
                size_t j = order[_j].first;
                if (!exist_box[j]) continue;
                float ovr = cal_iou(boxes[j], boxes[i]);
                if (ovr >= thres) exist_box[j] = false;
            }
        }
    }
    return result;
}

int8_t* getBinOfOutPut(int sizeOut, const char* output_node){
    FILE *fp;
    char *output_name;
    sprintf(output_name, "%s.bin", output_node);
    printf(output_name);
    fp = fopen(output_name, "rb");
    assert(fp != NULL);
    int8_t* ret = (int8_t*)malloc(sizeof(int8_t) * sizeOut);
    assert(ret != NULL);
    fread(ret, sizeof(int8_t), sizeOut, fp);
    return ret;
}

vector<float> getFloatResults(int sizeOut){
    ifstream infile;
    infile.open("results.txt");   //将文件流对象与文件连接起来
    assert(infile.is_open());   //若失败,则输出错误消息,并终止程序运行
    int i = -1;
    vector<float> ret(sizeOut,0);
    string s;
    while(getline(infile,s))
    {
        i+=1;
        ret[i] = str2float(s);
    }
    infile.close();             //关闭文件输入流
    return ret;

}

static float get_pixel(image m, int x, int y, int c)
{
    assert(x < m.w && y < m.h && c < m.c);
    return m.data[c*m.h*m.w + y*m.w + x];
}

static void set_pixel(image m, int x, int y, int c, float val)
{
    if (x < 0 || y < 0 || c < 0 || x >= m.w || y >= m.h || c >= m.c) return;
    assert(x < m.w && y < m.h && c < m.c);
    m.data[c*m.h*m.w + y*m.w + x] = val;
}

static void add_pixel(image m, int x, int y, int c, float val)
{
    assert(x < m.w && y < m.h && c < m.c);
    m.data[c*m.h*m.w + y*m.w + x] += val;
}

image make_empty_image(int w, int h, int c)
{
    image out;
    out.data = 0;
    out.h = h;
    out.w = w;
    out.c = c;
    return out;
}

void free_image(image m)
{
    if(m.data){
        free(m.data);
    }
}

image make_image(int w, int h, int c)
{
    image out = make_empty_image(w,h,c);
    out.data = (float*) calloc(h*w*c, sizeof(float));
    return out;
}

void fill_image(image m, float s)
{
    int i;
    for(i = 0; i < m.h*m.w*m.c; ++i) m.data[i] = s;
}

void embed_image(image source, image dest, int dx, int dy)
{
    int x,y,k;
    for(k = 0; k < source.c; ++k){
        for(y = 0; y < source.h; ++y){
            for(x = 0; x < source.w; ++x){
                float val = get_pixel(source, x,y,k);
                set_pixel(dest, dx+x, dy+y, k, val);
            }
        }
    }
}

void ipl_into_image(IplImage* src, image im)
{
    unsigned char *data = (unsigned char *)src->imageData;
    int h = src->height;
    int w = src->width;
    int c = src->nChannels;
    int step = src->widthStep;
    int i, j, k;

    for(i = 0; i < h; ++i){
        for(k= 0; k < c; ++k){
            for(j = 0; j < w; ++j){
                im.data[k*w*h + i*w + j] = data[i*step + j*c + k]/256.;
            }
        }
    }
}

image ipl_to_image(IplImage* src)
{
    int h = src->height;
    int w = src->width;
    int c = src->nChannels;
    image out = make_image(w, h, c);
    ipl_into_image(src, out);
    return out;
}

void rgbgr_image(image im)
{
    int i;
    for(i = 0; i < im.w*im.h; ++i){
        float swap = im.data[i];
        im.data[i] = im.data[i+im.w*im.h*2];
        im.data[i+im.w*im.h*2] = swap;
    }
}

image resize_image(image im, int w, int h)
{
    image resized = make_image(w, h, im.c);   
    image part = make_image(w, im.h, im.c);
    int r, c, k;
    float w_scale = (float)(im.w - 1) / (w - 1);
    float h_scale = (float)(im.h - 1) / (h - 1);
    for(k = 0; k < im.c; ++k){
        for(r = 0; r < im.h; ++r){
            for(c = 0; c < w; ++c){
                float val = 0;
                if(c == w-1 || im.w == 1){
                    val = get_pixel(im, im.w-1, r, k);
                } else {
                    float sx = c*w_scale;
                    int ix = (int) sx;
                    float dx = sx - ix;
                    val = (1 - dx) * get_pixel(im, ix, r, k) + dx * get_pixel(im, ix+1, r, k);
                }
                set_pixel(part, c, r, k, val);
            }
        }
    }
    for(k = 0; k < im.c; ++k){
        for(r = 0; r < h; ++r){
            float sy = r*h_scale;
            int iy = (int) sy;
            float dy = sy - iy;
            for(c = 0; c < w; ++c){
                float val = (1-dy) * get_pixel(part, c, iy, k);
                set_pixel(resized, c, r, k, val);
            }
            if(r == h-1 || im.h == 1) continue;
            for(c = 0; c < w; ++c){
                float val = dy * get_pixel(part, c, iy+1, k);
                add_pixel(resized, c, r, k, val);
            }
        }
    }

    free_image(part);
    return resized;
}

image load_image_cv(const char *filename, int channels)
{
    IplImage* src = 0;
    int flag = -1;
    if (channels == 0) flag = -1;
    else if (channels == 1) flag = 0;
    else if (channels == 3) flag = 1;
    else {
        fprintf(stderr, "OpenCV can't force load with %d channels\n", channels);
    }

    if( (src = cvLoadImage(filename, flag)) == 0 )
    {
        fprintf(stderr, "Cannot load image \"%s\"\n", filename);
        char buff[256];
        sprintf(buff, "echo %s >> bad.list", filename);
        // system(buff);
        return make_image(10,10,3);
        //exit(0);
    }
    image out = ipl_to_image(src);
    cvReleaseImage(&src);
    rgbgr_image(out);
    return out;
}

image load_image_cv(const cv::Mat& img) {
    int h = img.rows;
    int w = img.cols;
    int c = img.channels();
    image im = make_image(w, h, c);

    unsigned char *data = img.data;

    for(int i = 0; i < h; ++i){
        for(int k= 0; k < c; ++k){
            for(int j = 0; j < w; ++j){
                im.data[k*w*h + i*w + j] = data[i*w*c + j*c + k]/256.;
            }
        }
    }

    for(int i = 0; i < im.w*im.h; ++i){
        float swap = im.data[i];
        im.data[i] = im.data[i+im.w*im.h*2];
        im.data[i+im.w*im.h*2] = swap;
    }

    return im;
}

image letterbox_image(image im, int w, int h)
{
    int new_w = im.w;
    int new_h = im.h;
    if (((float)w/im.w) < ((float)h/im.h)) {
        new_w = w;
        new_h = (im.h * w)/im.w;
    } else {
        new_h = h;
        new_w = (im.w * h)/im.h;
    }
    image resized = resize_image(im, new_w, new_h);
    image boxed = make_image(w, h, im.c);
    fill_image(boxed, .5);
    //int i;
    //for(i = 0; i < boxed.w*boxed.h*boxed.c; ++i) boxed.data[i] = 0;
    embed_image(resized, boxed, (w-new_w)/2, (h-new_h)/2); 
    free_image(resized);
    return boxed;
}

image load_image_yolo(const char* file, int w, int h, int c) {
  image img = load_image_cv(file, c);
  image img_yolo = letterbox_image(img, w, h);
  return img_yolo;
}

