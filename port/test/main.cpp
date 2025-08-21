#include <iostream>
#include "mlt++/Mlt.h"

int main() {
    try {
        // Initialize MLT
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
