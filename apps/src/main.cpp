#include <algorithm>
#include <vector>
#include <atomic>
#include <queue>
#include <string>
#include <iostream>
#include <fstream>
#include <iomanip>
#include <chrono>
#include <mutex>
#include <zconf.h>
#include <thread>
#include <sys/stat.h>
#include <dirent.h>

#include "image.h"
#include "time_helper.hpp"

#define NMS_THRE  0.3

static int threadnum;
vector<string> images;
const string baseImagePath = "./image/";


//#define pred
VideoCapture video;
/* input meida name */
string video_name;

int idxInputImage = 0;  // image index of input video
int idxShowImage = 0;   // next frame index to be display
bool bReading = true;   // flag of input
chrono::system_clock::time_point start_time;

typedef pair<int, Mat> imagePair;
class paircomp {
public:
    bool operator()(const imagePair &n1, const imagePair &n2) const {
        if (n1.first == n2.first) return n1.first > n2.first;
        return n1.first > n2.first;
    }
};

mutex mtxQueueInput;               // mutex of input queue
mutex mtxQueueShow;                // mutex of display queue
queue<pair<int, Mat>> queueInput;  // input queue
priority_queue<imagePair, vector<imagePair>, paircomp>
        queueShow;  // display queue


#ifdef SHOWTIME
#define _T(func)                                                              \
    {                                                                         \
        auto _start = system_clock::now();                                    \
        func;                                                                 \
        auto _end = system_clock::now();                                      \
        auto duration = (duration_cast<microseconds>(_end - _start)).count(); \
        string tmp = #func;                                                   \
        tmp = tmp.substr(0, tmp.find('('));                                   \
        cout << "[TimeTest]" << left << setw(30) << tmp;                      \
        cout << left << setw(10) << duration << "us" << endl;                 \
    }
#else
#define _T(func) func;
#endif

const int classification = 3;
const int anchor = 5;

void correct_region_boxes(vector<vector<float>>& boxes, int n, int w, int h, int netw, int neth, int relative = 0) {
    int new_w=0;
    int new_h=0;
    if (((float)netw/w) < ((float)neth/h)) {
        new_w = netw;
        new_h = (h * netw)/w;
    } else {
        new_h = neth;
        new_w = (w * neth)/h;
    }
    for (int i = 0; i < n; ++i){
        boxes[i][0] =  (boxes[i][0] - (netw - new_w)/2./netw) / ((float)new_w/(float)netw);
        boxes[i][1] =  (boxes[i][1] - (neth - new_h)/2./neth) / ((float)new_h/(float)neth);
        boxes[i][2] *= (float)netw/new_w;
        boxes[i][3] *= (float)neth/new_h;
    }
}

void reader2(vector<string> images) {
    start_time = chrono::system_clock::now();
    int i = 0;
    while (1)
    {
        for (auto imagename : images) {
            Mat img;
			usleep(50000);
			if (queueInput.size() < 30) {
                img = imread(imagename);
                //cout<<imagename<<" img nums: "<<i++<<endl;
                mtxQueueInput.lock();
                queueInput.push(make_pair(idxInputImage++, img));
                mtxQueueInput.unlock();
            } else {
                usleep(10);
            }
        }
    }
}


void reader(vector<string> images) {
    start_time = chrono::system_clock::now();
    int i = 0;
    VideoCapture video;
	//video.open("/home/share/yolo-v3/sample_1.avi");
	if(!video.open(video_name)){
	cout<<"open vidio error! "<<endl;
	exit(-1);
	}
	while (1)
    {
		usleep(20000);
            Mat img;
            if (queueInput.size() < 30) {
                if (!video.read(img))
      				{
        				video.set(CV_CAP_PROP_POS_FRAMES,0);
        				continue;
      				}
				mtxQueueInput.lock();
                queueInput.push(make_pair(idxInputImage++, img));
                mtxQueueInput.unlock();
            } else {
                usleep(10);
            }
    }
}
/**
 * @brief image display thread handler.
 *
 * @param  none
 * @return none
 *
 */
void displayImage() {
    Mat img;
    while (true) {
        mtxQueueShow.lock();
        if (queueShow.empty()) {
            mtxQueueShow.unlock();
            usleep(10);
        } else if (idxShowImage == queueShow.top().first) {
            auto show_time = chrono::system_clock::now();
            stringstream buffer;
            Mat img = queueShow.top().second;
            auto dura = (duration_cast<microseconds>(show_time - start_time)).count();
            buffer << fixed << setprecision(2)
                   << (float)queueShow.top().first / (dura / 1000000.f);
            string a = buffer.str() + "FPS";
            cv::putText(img, a, cv::Point(10, 15), 1, 1, cv::Scalar{240, 240, 240},1);
            cv::imshow("YOLO @Deephi DPU", img);  // display image
            idxShowImage++;
            queueShow.pop();
            mtxQueueShow.unlock();
            if (waitKey(1) == 'q') {
                bReading = false;
                exit(0);
            }
        } else {
            mtxQueueShow.unlock();
        }
    }
}

void deal(DPUTask* task, Mat& img, string& imgname, int sw, int sh){

    const string outputs_node[4]= {"layer81_conv", "layer93_conv", "layer105_conv",  "layer117_conv"};
	const string classes[3] = {"car", "person", "cycle"};
    vector<vector<float>> boxes;
    for(int i = 0; i < 4; i++){
        string output_node = outputs_node[i];
        int channel = dpuGetOutputTensorChannel(task, output_node.c_str());
        int width = dpuGetOutputTensorWidth(task, output_node.c_str());
        int height = dpuGetOutputTensorHeight(task, output_node.c_str());

        int sizeOut = dpuGetOutputTensorSize(task, output_node.c_str());
        int8_t* dpuOut = dpuGetOutputTensorAddress(task, output_node.c_str());
        float scale = dpuGetOutputTensorScale(task, output_node.c_str());
		vector<float> result(sizeOut);
		boxes.reserve(sizeOut);
        get_output(dpuOut, sizeOut, scale, channel, height, width, result);
		//__TIC__(detect);
        detect(boxes, result, channel, height, width, i, sh, sw);
		//__TOC__(detect);
    }
		//__TIC__(nms);
    correct_region_boxes(boxes, boxes.size(), img.cols, img.rows, sw, sh);
    vector<vector<float>> res = apply_nms(boxes, classification, NMS_THRE);

		//__TOC__(nms);
    float h = img.rows;
    float w = img.cols;
    for(size_t i = 0; i < res.size(); ++i){
        float xmin = (res[i][0] - res[i][2]/2.0) * w + 1.0;
        float ymin = (res[i][1] - res[i][3]/2.0) * h + 1.0;
        float xmax = (res[i][0] + res[i][2]/2.0) * w + 1.0;
        float ymax = (res[i][1] + res[i][3]/2.0) * h + 1.0;
      //  if(xmin < 1) xmin = 1;
      //  if(xmax > w) xmax = w;
      //  if(ymin < 1) ymin = 1;
      //  if(ymax > h) ymax = h;
    //    
	if(res[i][res[i][4] + 6] > CONF ) {
		int type = res[i][4];
		string classname = classes[type];
            	if (type==0){
			rectangle(img, cvPoint(xmin, ymin), cvPoint(xmax, ymax), Scalar(0, 0, 255), 1, 1, 0);
		}
		else if (type==1){
			rectangle(img, cvPoint(xmin, ymin), cvPoint(xmax, ymax), Scalar(255, 0, 0), 1, 1, 0);
		}
		else {
			rectangle(img, cvPoint(xmin, ymin), cvPoint(xmax, ymax), Scalar(0 ,255, 255), 1, 1, 0);
		}

		//cout << imgname << " " << classname<<" "<<res[i][6 + res[i][4]] <<" " << xmin << " " << ymin << " " << xmax << " " << ymax << "\n";
            }
    }
}
void detect(vector<vector<float>> &boxes, vector<float> result, int channel, int height, int width, int num, int sh, int sw) {
    {
        //vector<float> biases{6.7,14.3,  14.4,31.65,  14.3,59, 70,96,  111,155,  80,258, 42,55,  23,102,  39.8,167};
//        vector<float> biases{5.5,7, 8,17, 14,11, 13,29, 24,17, 18,46, 33,29, 47,23, 28,68, 52,42, 76,37, 40,97, 74,64, 105,63, 66,131, 123,100, 167,83, 98,174, 165,158, 347,98};
        vector<float> biases{123,100, 167,83, 98,174, 165,158, 347,98, 76,37, 40,97, 74,64, 105,63, 66,131, 18,46, 33,29, 47,23, 28,68, 52,42, 5.5,7, 8,17, 14,11, 13,29, 24,17 };
		int conf_box = 5 + classification;
	//	cout<<" height: "<<height<<" width: "<<width<<endl;
//__TIC__(swap);	
        float swap[height * width][anchor][conf_box];
        for (int h = 0; h < height; ++h) {
            for (int w = 0; w < width; ++w) {
                for (int c = 0; c < channel; ++c) {
                    int temp = c * height * width + h * width + w;
                    swap[h * width + w][c / conf_box][c % conf_box] = result[temp];
                }
            }
        }
//__TOC__(swap);	
//__TIC__(sigmod);	
	//	cout<<"height: width: c: " << height<<"  "<<width<<" "<<anchor<<endl;
        for (int h = 0; h < height; ++h) {
            for (int w = 0; w < width; ++w) {
                for (int c = 0; c < anchor; ++c) {
                    float obj_score = sigmoid(swap[h * width + w][c][4]);
                    if (obj_score < CONF)
                        continue;
                    vector<float> box;
                    //box.reserve(7+classification);
                    box.push_back((w + sigmoid(swap[h * width + w][c][0])) / width);
                    box.push_back((h + sigmoid(swap[h * width + w][c][1])) / height);
                    box.push_back(exp(swap[h * width + w][c][2]) * biases[2 * c + 10 * num] / float(sw));
                    box.push_back(exp(swap[h * width + w][c][3]) * biases[2 * c + 10 * num + 1] / float(sh));
                    box.push_back(-1);                   // class
                    box.push_back(obj_score);                   // this class's conf
                    for (int p = 0; p < classification; p++) {
                        box.push_back(obj_score * sigmoid(swap[h * width + w][c][5 + p]));
                    }
                    boxes.push_back(box);
                }
            }
        }
//__TOC__(sigmod);	
    }

}
void run_yolo(DPUTask* task) {
    float mean[3] = {0, 0, 0};
    int sh = dpuGetInputTensorHeight(task, INPUTNODE);
    int sw = dpuGetInputTensorWidth(task, INPUTNODE);

    while (1) {
        pair<int, Mat> pairIndexImage;
        mtxQueueInput.lock();
        if (queueInput.empty()) {
            mtxQueueInput.unlock();
            if (bReading)
                continue;
            else
                break;
        } else {
            // Get an image from input queue
            pairIndexImage = queueInput.front();
            queueInput.pop();
            mtxQueueInput.unlock();
        }
        vector<vector<float>> res;
        /* Set image into CONV Task with mean value */
        set_input_image(task, pairIndexImage.second, mean, INPUTNODE);
        dpuRunTask(task);
        string tempstr = "hello.jpg";
        deal(task, pairIndexImage.second, tempstr, sw, sh);
        mtxQueueShow.lock();
        // Put the processed iamge to show queue
        queueShow.push(pairIndexImage);
        mtxQueueShow.unlock();
    }
}

void run_yolo2(DPUTask* task, Mat img, string imgname) {
    float mean[3] = {0, 0, 0};
    int sh = dpuGetInputTensorHeight(task, INPUTNODE);
    int sw = dpuGetInputTensorWidth(task, INPUTNODE);

        vector<vector<float>> res;
        /* Set image into CONV Task with mean value */
		__TIC__(setimage);
        set_input_image(task, img, mean, INPUTNODE);
		__TOC__(setimage);
		__TIC__(runtask);
        dpuRunTask(task);
		__TOC__(runtask);
		__TIC__(deal);
        string ext = imgname.substr(0, imgname.find_last_of("."));
        deal(task, img, ext, sw, sh);
		__TOC__(deal);
}
void ListImages(string const &path, vector<string> &images) {
    images.clear();
    struct dirent *entry;

    /*Check if path is a valid directory path. */
    struct stat s;
    lstat(path.c_str(), &s);
    if (!S_ISDIR(s.st_mode)) {
        fprintf(stderr, "Error: %s is not a valid directory!\n", path.c_str());
        exit(1);
    }

    DIR *dir = opendir(path.c_str());
    if (dir == nullptr) {
        fprintf(stderr, "Error: Open %s path failed.\n", path.c_str());
        exit(1);
    }

    while ((entry = readdir(dir)) != nullptr) {
        if (entry->d_type == DT_REG || entry->d_type == DT_UNKNOWN) {
            string name = entry->d_name;
            string ext = name.substr(name.find_last_of(".") + 1);
            if ((ext == "JPEG") || (ext == "jpeg") || (ext == "JPG") || (ext == "jpg") ||
                (ext == "PNG") || (ext == "png")) {
                images.push_back(name);
            }
        }
    }

    closedir(dir);
}

int8_t* data;

void classifyEntry(DPUKernel *kernelconv) {
    ListImages(baseImagePath, images);
    if (images.size() == 0) {
        cerr << "\nError: Not images exist in " << baseImagePath << endl;
        return;
    } else {
        cout << "total image : " << images.size() << endl;
    }
    thread workers[threadnum];
    atomic<int> n(0);
    Mat img = imread(baseImagePath + images.at(0));
    int size = 256* 512 * 13;
    data = new int8_t[size];
    set_data(img, data);
    auto _start = system_clock::now();
    auto time1 = system_clock::now();
    for (auto i = 0; i < threadnum; i++) {
        workers[i] = thread([&,i]() {
            // Create DPU Tasks from DPU Kernel
            DPUTask *taskconv = dpuCreateTask(kernelconv, 0);
            int sh = dpuGetInputTensorHeight(taskconv, INPUTNODE);
            int sw = dpuGetInputTensorWidth(taskconv, INPUTNODE);
            DPUTask *task = dpuCreateTask(kernelconv, 0);
            for(; ;) {
                set_input_img2(taskconv, INPUTNODE, data);
                dpuRunTask(taskconv);
                string strimg = "test.jpg";
                deal(taskconv, img, strimg, sw, sh);
                auto time2 = system_clock::now();
                if(n%100 == 0 && n != 0) {
                    auto duration = (duration_cast<microseconds>(time2 - time1)).count();
                    cout << " [FPS]" << 100*1000000.0/duration  << endl;
                    time1 = time2;
                }
                n++;
            }

            // Destroy DPU Tasks & free resources
            dpuDestroyTask(taskconv);
            delete[] data;
        });
    }
    // Release thread resources.
    for (auto &w : workers) {
        if (w.joinable()) w.join();
    }


    auto _end = system_clock::now();
    auto duration = (duration_cast<microseconds>(_end - _start)).count();
    cout << "[Time]" << duration << "us" << endl;
    cout << "[FPS]" << images.size()*1000000.0/duration  << endl;
}

int main(const int argc, const char** argv) {
    if (argc != 3) {
          cout << "Usage of this exe: ./yolo image_name[string] i"
             << endl;
          cout << "Usage of this exe: ./yolo vedio_name[string] v"
               << endl;
          cout << "Usage of this exe: ./yolo thread_num[int] p"
               << endl;
        return -1;
      }
    string model = argv[2];
    if (model == "p" ) {
        threadnum = stoi(argv[1]);
        dpuOpen();
        DPUKernel *kernel = dpuLoadKernel("yolo");
        classifyEntry(kernel);
        dpuDestroyKernel(kernel);
        dpuClose();
        return 0;
    }
    else if (model == "i") {
        dpuOpen();
        DPUKernel *kernel = dpuLoadKernel("yolo");
        DPUTask *task = dpuCreateTask(kernel, 0);
        string pathname = argv[1];
		vector<string> images;
		ListImages(pathname, images);
		for(auto imgname : images){
			Mat img = imread(pathname+imgname);
			Mat resimg;
			resize(img, resimg, Size(512, 256));
			imwrite("resize.png", resimg);
			run_yolo2(task, img, imgname);
			cv::imshow("yolo-v3", img);
        	cv::waitKey(0);
		}	
        dpuDestroyTask(task);
        dpuDestroyKernel(kernel);
        dpuClose();
        return 0;
    }
    else if(model == "v"){
        video_name = argv[1];
        dpuOpen();
        DPUKernel *kernel = dpuLoadKernel("yolo");
        vector<DPUTask *> task(4);
        generate(task.begin(), task.end(), std::bind(dpuCreateTask, kernel, 0));
        array<thread, 6> threads = {
                thread(run_yolo, task[0]),
                thread(run_yolo, task[1]),
                thread(run_yolo, task[2]),
                thread(run_yolo, task[3]),
                thread(displayImage),
                thread(reader,images)
        };

        for (int i = 0; i < 6; i++) {
            threads[i].join();
        }
        for_each(task.begin(), task.end(), dpuDestroyTask);
        dpuDestroyKernel(kernel);
        dpuClose();
        return 0;
    }
    else {
          cout << "unknow type !"<<endl;    
          cout << "Usage of this exe: ./yolo image_name[string] i"
             << endl;
          cout << "Usage of this exe: ./yolo vedio_name[string] v"
               << endl;
          cout << "Usage of this exe: ./yolo thread_num[int] p"
               << endl;
        return -1;
    }
}
