#include <iostream>
#include <string>
#include <cstdlib>
#include "mlt++/Mlt.h"

// Display current MLT environment variables
void show_mlt_environment() {
    const char* mlt_repository = getenv("MLT_REPOSITORY");
    const char* mlt_data = getenv("MLT_DATA");
    const char* mlt_appdir = getenv("MLT_APPDIR");
    
    std::cout << "MLT Environment Variables:" << std::endl;
    std::cout << "MLT_REPOSITORY=" << (mlt_repository ? mlt_repository : "not set") << std::endl;
    std::cout << "MLT_DATA=" << (mlt_data ? mlt_data : "not set") << std::endl;
    std::cout << "MLT_APPDIR=" << (mlt_appdir ? mlt_appdir : "not set") << std::endl;
}

int main() {
    try {
        // Display environment variables
        show_mlt_environment();
        
        // Initialize MLT - let it find modules through environment variables
        Mlt::Factory::init();
        
        std::cout << "MLT Test Application" << std::endl;
        std::cout << "===================" << std::endl;
        
        // Get MLT version
        std::cout << "MLT Version: " << mlt_version_get_string() << std::endl;
        
        // Create a profile
        Mlt::Profile profile;
        std::cout << "Default Profile: " << profile.width() << "x" << profile.height() 
                  << " @ " << profile.fps() << " fps" << std::endl;
        
        // Create a simple color producer
        Mlt::Producer producer(profile, "color:blue");
        if (producer.is_valid()) {
            std::cout << "Color producer created successfully" << std::endl;
            std::cout << "Duration: " << producer.get_length() << " frames" << std::endl;
        } else {
            std::cout << "Failed to create color producer" << std::endl;
            return 1;
        }
        
        // Test repository access
        Mlt::Repository* repo = Mlt::Factory::init();
        if (repo) {
            Mlt::Properties* consumers = repo->consumers();
            std::cout << "Available consumers: " << consumers->count() << std::endl;
            
            Mlt::Properties* producers = repo->producers();
            std::cout << "Available producers: " << producers->count() << std::endl;
            
            Mlt::Properties* filters = repo->filters();
            std::cout << "Available filters: " << filters->count() << std::endl;
            
            // 查找frei0r过滤器
            bool found_frei0r = false;
            std::cout << "Searching for frei0r filters..." << std::endl;
            for (int i = 0; i < filters->count(); i++) {
                std::string filter_name = filters->get_name(i);
                if (filter_name.find("frei0r") != std::string::npos) {
                    found_frei0r = true;
                    std::cout << "Found frei0r filter: " << filter_name << std::endl;
                }
            }
            if (!found_frei0r) {
                std::cout << "No frei0r filters found." << std::endl;
            }
            
            // 尝试加载一个frei0r过滤器
            Mlt::Filter* frei0r_test = NULL;
            try {
                frei0r_test = new Mlt::Filter(profile, "frei0r.cartoon");
                if (frei0r_test && frei0r_test->is_valid()) {
                    std::cout << "Successfully created frei0r.cartoon filter!" << std::endl;
                    delete frei0r_test;
                } else {
                    std::cout << "Failed to create frei0r.cartoon filter." << std::endl;
                    if (frei0r_test) delete frei0r_test;
                }
            } catch (std::exception& ex) {
                std::cout << "Exception creating frei0r filter: " << ex.what() << std::endl;
                if (frei0r_test) delete frei0r_test;
            }
        }
        
        std::cout << std::endl << "MLT test completed successfully!" << std::endl;
        
        // Cleanup
        Mlt::Factory::close();
        
    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return 1;
    }
    
    return 0;
}
