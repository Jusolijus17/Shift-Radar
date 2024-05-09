//
//  ProfileImage.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2024-05-05.
//

import SwiftUI

struct ProfileImage<Placeholder: View>: View {
    var imageURL: URL?
    var placeholder: () -> Placeholder
    @Binding var selectedImage: UIImage?
    var width: CGFloat
    var height: CGFloat

    init(image: Binding<UIImage?>, imageURL: String? = nil, width: CGFloat, height: CGFloat, @ViewBuilder placeholder: @escaping () -> Placeholder) {
        self._selectedImage = image
        self.placeholder = placeholder
        self.width = width
        self.height = height
        if let imageURL = imageURL {
            self.imageURL = URL(string: imageURL)
        }
    }
    
    var body: some View {
        Group {
            if let selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFill()
                    .overlay {
                        Circle()
                            .stroke(.red, lineWidth: 2)
                    }
                    .clipShape(Circle())
                    .frame(width: width, height: height)
                    .clipped()
            } else if let imageURL {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .success(let loadedImage):
                        loadedImage
                            .resizable()
                            .scaledToFill()
                            .overlay {
                                Circle()
                                    .stroke(.accent, lineWidth: 2)
                            }
                            .clipShape(Circle())
                            .frame(width: width, height: height)
                    case .failure:
                        placeholder()
                    case .empty:
                        placeholder()
                    @unknown default:
                        placeholder()
                    }
                }
            } else {
                placeholder()
            }
        }
    }

    func editable() -> some View {
        modifier(EditableProfileImage(selectedImage: $selectedImage))
    }

    func expandable() -> some View {
        modifier(ExpandableImageModifier(image: selectedImage))
    }
}


struct EditableProfileImage: ViewModifier {
    @Binding var selectedImage: UIImage?
    @State private var isShowingActionSheet = false
    @State private var isShowingImagePicker = false

    func body(content: Content) -> some View {
        content
            .overlay {
                Image(systemName: "pencil.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.green)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            }
            .onTapGesture {
                isShowingActionSheet = true
            }
            .actionSheet(isPresented: $isShowingActionSheet) {
                ActionSheet(
                    title: Text("Edit profile picture"),
                    buttons: [
                        .default(Text("Change picture")) {
                            isShowingImagePicker = true
                        },
                        .destructive(Text("Delete picture")) {
                            selectedImage = nil
                        },
                        .cancel()
                    ]
                )
            }
            .sheet(isPresented: $isShowingImagePicker) {
                ImagePicker(sourceType: .photoLibrary, selectedImage: $selectedImage)
                    .ignoresSafeArea()
            }
    }
}

struct ExpandableImageModifier: ViewModifier {
    @State var isShowingFullImage = false
    var image: UIImage?

    func body(content: Content) -> some View {
        content
            .onTapGesture {
                self.isShowingFullImage = true
            }
            .fullScreenCover(isPresented: $isShowingFullImage) {
                ZStack {
                    Color.black
                        .ignoresSafeArea()
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .edgesIgnoringSafeArea(.all)
                    }
                }
                .onTapGesture {
                    self.isShowingFullImage = false
                }
            }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) private var presentationMode
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Binding var selectedImage: UIImage?
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                parent.selectedImage = image
            } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.selectedImage = originalImage
            }

            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct ProfileImage_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }
    
    struct PreviewWrapper: View {
        @State private var image: UIImage?
        init() {
        }
        
        var body: some View {
            ProfileImage(image: $image, width: 100, height: 100) {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            }
            .editable()
        }
    }
}
