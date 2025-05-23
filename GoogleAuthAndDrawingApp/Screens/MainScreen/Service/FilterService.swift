import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

class FilterService {
    static let shared = FilterService()
    
    private let context = CIContext()
    
    private var currentFilter: CIFilter?
    
    enum FilterType: String, CaseIterable {
        case sepia = "Sepia"
        case chrome = "Chrome"
        case noir = "Noir"
        case vignette = "Vignette"
        case bloom = "Bloom"
        case none = "Original"
    }
    
    func applyFilter(_ filterType: FilterType, to image: UIImage) -> UIImage? {
        guard filterType != .none else { return image }
        
        guard let ciImage = CIImage(image: image) else { return nil }
        
        let filter: CIFilter
        
        switch filterType {
        case .sepia:
            filter = CIFilter.sepiaTone()
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(1.0, forKey: kCIInputIntensityKey)
            
        case .noir:
            filter = CIFilter.photoEffectNoir()
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            
        case .vignette:
            filter = CIFilter.vignette()
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(1.0, forKey: kCIInputIntensityKey)
            filter.setValue(0.5, forKey: kCIInputRadiusKey)
            
        case .bloom:
            filter = CIFilter.bloom()
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(1.0, forKey: kCIInputIntensityKey)
            filter.setValue(5.0, forKey: kCIInputRadiusKey)
            
        case .chrome:
            filter = CIFilter.photoEffectChrome()
            filter.setValue(ciImage, forKey: kCIInputImageKey)
        case .none:
            return image
        }
        
        
        currentFilter = filter
        
        guard let outputImage = filter.outputImage,
              let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
}
