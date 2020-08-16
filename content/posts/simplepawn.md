---
title: "UE4 Plugin: A Simple Pawn"
date: 2020-08-16T11:45:56+01:00
draft: true
image: MeepleOnTarget.png
---
This article will explain how to create simple user controlled Pawn as an Unreal Engine 4 plugin.

# Prerequisites
If you want to create it yourself:
1. Create a UE4 C++ project ([docs](https://docs.unrealengine.com/en-US/Engine/Basics/Projects/Browser/index.html#:~:text=First%2C%20click%20the%20Blueprint%20dropdown,with%20C%2B%2B%20in%20Visual%20Studio.))
1. Create a new blank plugin ([docs](https://docs.unrealengine.com/en-US/Programming/Plugins/index.html))
1. Create a new level (Default or TimeOfDay) ([docs](https://docs.unrealengine.com/en-US/Engine/QuickStart/index.html#3.createanewlevel))
1. (Optional) Download assets for this article
1. (Optional) Import assets ([docs](https://docs.unrealengine.com/en-US/Engine/Content/Importing/FBX/HowTo/ImportingMeshes/index.html))

If you want to read along
1. Create a `Plugins` directory in the top level directory of your project
1. Clone (or download) SimplePawn in the `Plugins` directory 

## Additional notes
 
* If you want to create new C++ classes it is advisable to add them via the 
[Unreal Editor C++ Class Wizard](https://docs.unrealengine.com/en-US/Programming/Development/ManagingGameCode/CppClassWizard/index.html).
* Unreal Engine 4.25
 
## Architecture
![Simple Pawn Architecture](/svg/SimplePawnArchitecture.svg)
A Pawn is the UE4 base class of all Actors which can be possesed by players or AI. 
As a start you need to add your own implementation of a Pawn and Movement Component.

After the implementation you can than add static mesh component, the 3d model (static mesh), 
the camera spring arm, the camera and the custom movement component to the custom pawn.
(All of this happens in the constructor of the Pawn).

## Implementation
### Pawn Implementation

Custom implementation inheriting from `APawn`
```c++ 
UCLASS()
class MM_MULTITHREADING_API ASimplePawn : public APawn
{ ... }
```


### Movement Component Implementation

Custom implementation inheriting from `UPawnMovementComponent`
```c++
UCLASS()
class MM_MULTITHREADING_API USimplePawnMovementComponent 
: public UPawnMovementComponent
{ ... }
```


### Composition of Components to the Custom Pawn
Following the [Composite Design Pattern](https://en.wikipedia.org/wiki/Composite_pattern) we will add a 
 static mesh component (`UStaticMeshComponent`), a camera on a springarm and the custom movement component. 
```c++
UPROPERTY(Category=Mesh, VisibleDefaultsOnly, BlueprintReadOnly)
class UStaticMeshComponent *MeepleComponent;

UPROPERTY(Category=Camera, VisibleDefaultsOnly, BlueprintReadOnly)
class USpringArmComponent* SpringArm;

UPROPERTY(Category=Camera, VisibleDefaultsOnly, BlueprintReadOnly)
class UCameraComponent* Camera;

private:
UPROPERTY()
class USimplePawnMovementComponent* SimplePawnMovementComponent;
```

### Adding the 3D Model (Static Mesh) 
The static mesh component on its own doesn't have mesh data, the actual polygon data is added 
in the constructor with a static mesh object (`UStaticMesh`)

```c++
struct FConstructorStatics
{
    ConstructorHelpers::FObjectFinderOptional<UStaticMesh> MeepleMesh;
    FConstructorStatics()
        : MeepleMesh(TEXT("/MM_MultiThreading/Meeple.Meeple")) {}
};
static FConstructorStatics ConstructorStatics;

MeepleComponent = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("Meeple"));
MeepleComponent->SetStaticMesh(ConstructorStatics.MeepleMesh.Get());
RootComponent = MeepleComponent;
```

### Initialisation of the Spring Arm
The spring arm component allows the camera to accelerate and decelerate more slowy then the Pawn 
(smoothing the camera path) and it also prevents the camera to go through solid objects.
```c++
SpringArm = CreateDefaultSubobject<USpringArmComponent>(TEXT("SpringArm0"));
SpringArm->SetupAttachment(RootComponent);

const FVector SpringArmLocation = FVector(-550.f,0.f,440.f);
const FRotator SpringArmRotation = FRotator(-30, 0, 0);

SpringArm->SetRelativeLocation(SpringArmLocation);
SpringArm->SetRelativeRotation(SpringArmRotation);
SpringArm->TargetArmLength = .0f;	
```
### Initialisation of the Camera
```c++
Camera = CreateDefaultSubobject<UCameraComponent>(TEXT("Camera0"));
Camera->SetupAttachment(SpringArm, USpringArmComponent::SocketName);	
Camera->bUsePawnControlRotation = false; 
```

### Initialisation of the Custom Movement Component

```c++
SimplePawnMovementComponent = CreateDefaultSubobject<USimplePawnMovementComponent>(TEXT("CustomMovementComponent"));
SimplePawnMovementComponent->UpdatedComponent = RootComponent;
```

## Linking it all together


 

 

