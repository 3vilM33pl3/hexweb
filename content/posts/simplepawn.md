---
title: "UE4 Plugin: A Simple Pawn"
date: 2020-08-16T11:45:56+01:00
draft: false
image: MeepleOnTarget.png
---
This article will explain how to create simple user controlled Pawn which can only move forward and backwards. 
The whole application is wrapped in a UE4 plugin.

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
 
* If you want to create new C++ classes you need to use the 
[Unreal Editor C++ Class Wizard](https://docs.unrealengine.com/en-US/Programming/Development/ManagingGameCode/CppClassWizard/index.html).
* Unreal Engine 4.25
* Documentation [UE4 Plugin Development](https://docs.unrealengine.com/en-US/Programming/Plugins/index.html)

## Architecture
![Simple Pawn Architecture](/svg/SimplePawnArchitecture.svg)
A Pawn is the UE4 base class of all Actors which can be possesed by players or AI. 
By following the [composite reuse pattern](https://en.wikipedia.org/wiki/Composition_over_inheritance), 
in this example, the Pawn's functionality gets extended by adding the following components:
* Static mesh component (`UStaticMeshComponent`)
* Camera component (`UCameraComponent`)
* Spring arm component (`USpringArmComponent`)
* Movement component (`UPawnMovementComponent`) 

These components are initialised in the constructor of the Pawn together with a static mesh object 
containing a 3D model. The static mesh _object_ (`UStaticMesh`) gets added to the static mesh _component_ (`UStaticMeshComponent`).
The static mesh component in itself doesn't hold any polygon data.

## Implementation
### Custom Pawn Inherits from `APawn`
This class needs to be created with the [Unreal Editor C++ Class Wizard](https://docs.unrealengine.com/en-US/Programming/Development/ManagingGameCode/CppClassWizard/index.html).
It's a class used during _Runtime_ and is located in a module (folder) in the `Source` folder of the plugin.
```c++ 
UCLASS()
class MM_MULTITHREADING_API ASimplePawn : public APawn
{ ... }
```
In the newly created class the following methods are overridden:
* `BeginPlay()`
* `Tick(..)`
* `SetupPlayerInputComponent(..)` 

### Custom Movement Component Inherits from `UPawnMovementComponent`
This class needs to be created with the [Unreal Editor C++ Class Wizard](https://docs.unrealengine.com/en-US/Programming/Development/ManagingGameCode/CppClassWizard/index.html).
It's a class used during _Runtime_ and is located in a module (folder) in the `Source` folder of the plugin.
```c++
UCLASS()
class MM_MULTITHREADING_API USimplePawnMovementComponent 
: public UPawnMovementComponent
{ ... }
```

### Composition of Components in the Custom Pawn
_This code is part of the pawn's class declaration_
```c++
public:
UPROPERTY(Category=Mesh, VisibleDefaultsOnly, BlueprintReadOnly)
class UStaticMeshComponent *MeepleComponent;

UPROPERTY(Category=Camera, VisibleDefaultsOnly, BlueprintReadOnly)
class USpringArmComponent* SpringArm;

UPROPERTY(Category=Camera, VisibleDefaultsOnly, BlueprintReadOnly)
class UCameraComponent* Camera;

UPROPERTY()
class USimplePawnMovementComponent* SimplePawnMovementComponent;
```

Needs these two includes:
```c++
#include "Camera/CameraComponent.h"
#include "GameFramework/SpringArmComponent.h"
```


### Adding the 3D Model (Static Mesh) 
_This code lives in the pawn's constructor_

The static mesh component on its own doesn't have mesh data, the actual polygon data is added 
in the constructor with a static mesh object (`UStaticMesh`)

```c++
struct FConstructorStatics
{
    ConstructorHelpers::FObjectFinderOptional<UStaticMesh> MeepleMesh;
    FConstructorStatics()
        : MeepleMesh(TEXT("/MeMoSimplePawn/Meeple.Meeple")) {}
};
static FConstructorStatics ConstructorStatics;

MeepleComponent = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("Meeple"));
MeepleComponent->SetStaticMesh(ConstructorStatics.MeepleMesh.Get());
RootComponent = MeepleComponent;
```
The `RootComponent` defines the transform (location, rotation, scale) of this Pawn in the world. 
All other components need to be attached to this, be it directly or via other components.

The `TEXT` string of the MeepleMesh is composed of the plugin name and the name of the mesh 
(twice with a dot in the middle). This will point to the `Content` directory of the plugin: 

![](/images/PluginContentDir.png)

Download the <a href="/fbx/meeple.fbx" download>Meeple 3D Model</a> which can be used for importing in UE4 <a href="/fbx/meeple.fbx" download>here</a>.

### Initialisation of the Spring Arm
_This code lives in the pawn's constructor_

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
The spring arm is attached to the root component.

### Initialisation of the Camera
_This code lives in the pawn's constructor_

```c++
Camera = CreateDefaultSubobject<UCameraComponent>(TEXT("Camera0"));
Camera->SetupAttachment(SpringArm, USpringArmComponent::SocketName);	
Camera->bUsePawnControlRotation = false; 
```
The camera is attached to the spring arm.

### Initialisation of the Custom Movement Component
_This code lives in the pawn's constructor_

```c++
SimplePawnMovementComponent = CreateDefaultSubobject<USimplePawnMovementComponent>(TEXT("CustomMovementComponent"));
SimplePawnMovementComponent->UpdatedComponent = RootComponent;
```

### Auto Possess 
_This code lives in the pawn's constructor_
To activate (possess) this pawn and give control to the player when the game starts or when it gets spawned:
```c++
AutoPossessPlayer = EAutoReceiveInput::Player0;
```
This can also be set in the Editor

### Moving Forward Method
_This code is implemented in the pawn_
For the actor to move forward it needs to have a method to tell the movement component how much it has to move
based on the input of the player.

In class definition:
```c++
private:
void MoveForward(float AxisValue);
```
Implementation:
```c++
void ASimplePawn::MoveForward(float AxisValue)
{
	if (SimplePawnMovementComponent && (SimplePawnMovementComponent->UpdatedComponent == RootComponent))
	{
		SimplePawnMovementComponent->AddInputVector(GetActorForwardVector() * AxisValue);
	}	
}
```
First there is a a check to see if the movement component exists and if it is the root component.
If so, the `AxisValue` (usually between 0 and 1) gets multiplied with vector pointing in the direction 
it is meant to go when the player pushes/activates/clicks the joystick/.../key which is associated with
the (in this case()) forward movement. Moving backward is using the same method by inputting a negative value. 

### Bind Moving Forward Method to _MoveForward_ Axis
_This code is implemented in the pawn_
This overridden method is auto generated by the Unreal C++ Class Wizard. It only needs to bind the 
movement method with the correct axis.
Implementation:
```c++
void ASimplePawn::SetupPlayerInputComponent(UInputComponent* PlayerInputComponent)
{
	Super::SetupPlayerInputComponent(PlayerInputComponent);
	PlayerInputComponent->BindAxis("MoveForward", this, &ASimplePawn::MoveForward);
}
```
In the project settings under Engine -> Input, the "MoveForward" string can be mapped to specific keys or other input devices
{{< imgcenterresize "/images/BindingAxis.png" "50%" >}}

### Moving
_This code is implemented in the movement component_

Every frame the movement component has to move the pawn in the desired direction based on the players input
or other external factors. The following (generic) implementation can deal with movement requests in any direction. 
To execute code in a component every frame the `TickComponent(..)` method needs to be overriden

In class definition:
```c++
public:
virtual void TickComponent(float DeltaTime, ELevelTick TickType,
    FActorComponentTickFunction* ThisTickFunction) override;
```
Implementation:
```c++
void USimplePawnMovementComponent::TickComponent(float DeltaTime, ELevelTick TickType,
    FActorComponentTickFunction* ThisTickFunction)
{
    Super::TickComponent(DeltaTime, TickType, ThisTickFunction);

    if (!PawnOwner || !UpdatedComponent || ShouldSkipUpdate(DeltaTime))
    {
        return;
    }

    FVector DesiredMovementThisFrame = ConsumeInputVector().GetClampedToMaxSize(1.0f) * DeltaTime * 150.0f;
    if (!DesiredMovementThisFrame.IsNearlyZero())
    {
        FHitResult Hit;
        SafeMoveUpdatedComponent(DesiredMovementThisFrame, UpdatedComponent->GetComponentRotation(), true, Hit);
    }
}
```
After calling the parent method and some checks, the input vector is consumed and set to zero. This is the same vector 
which is set with `SimplePawnMovementComponent->AddInputVector(GetActorForwardVector() * AxisValue);` in the 
`MoveForward()` method above. The `ConsumeInputVector()` will read the value and return it after it sets the vector 
to zero. (Hence it is called "consume").

### For Efficiency 
```c++
UPawnMovementComponent* ASimplePawn::GetMovementComponent() const
{
	return SimplePawnMovementComponent;
}
```
UE4 uses reflection to determine if there is a custom movement component. 
Implementing this method which immediately returns the movement component, 
instead of looking it up, is more efficient.   


## Executing
Drag the `SimplePawn` from the plugin C++ folder into your level and press forward :-)

