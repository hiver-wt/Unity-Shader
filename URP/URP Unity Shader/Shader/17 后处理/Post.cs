using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class Post : ScriptableRendererFeature
{
    [System.Serializable]public class mysetting
    {
        // 渲染通道事件，指定自定义渲染通道应在哪个渲染事件之后执行。
        // 默认设置为在渲染透明对象之后执行。
        public RenderPassEvent passEvent = RenderPassEvent.AfterRenderingTransparents;
        
        // 用于自定义渲染通道的材质。
        public Material myMat;
        
        // 材质的通道索引。默认值为 -1，表示没有特定的通道。
        public int matPassIndex = -1;
    }
    public mysetting setting=new mysetting(); 
    class CustomRenderPass : ScriptableRenderPass
    {
        public Material passMat = null;
        public int passMatInt = 0;
        public FilterMode passFilterMode { get; set; }//图像的模式
        private RenderTargetIdentifier passSrc { get; set; }//源图像
        private RenderTargetHandle passTempleColorTex;//临时计算图像
        private string passTag;

        //构造函数
        public CustomRenderPass(RenderPassEvent passEvent, Material mat, int passInt, string tag)
        {
            this.renderPassEvent = passEvent;
            this.passMat = mat;
            this.passMatInt = passInt;
            passTag = tag;
        }

        public void setup(RenderTargetIdentifier src)//接收render feather传的图
        {
            this.passSrc = src;
        }
        
        // 在执行渲染通道之前调用此方法。
        // 可用于配置渲染目标及其清除状态，还可以创建临时渲染目标纹理。
        // 当此渲染通道为空时，将渲染到活动摄像机的渲染目标。
        // 永远不应该调用 CommandBuffer.SetRenderTarget。而是调用 ConfigureTarget 和 ConfigureClear。
        // 渲染管线将确保以高效的方式设置和清除渲染目标。
        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
            // 在此处实现渲染目标的配置和清除状态的设置
        }

        // 在这里可以实现渲染逻辑。
        // 使用 ScriptableRenderContext 发出绘制命令或执行命令缓冲区
        // 无需调用 ScriptableRenderContext.submit，渲染管线将在管线的特定点调用它。
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            CommandBuffer cmd = CommandBufferPool.Get(passTag);
            RenderTextureDescriptor opaqueDesc = renderingData.cameraData.cameraTargetDescriptor;
            opaqueDesc.depthBufferBits = 0;
            cmd.GetTemporaryRT(passTempleColorTex.id,opaqueDesc,passFilterMode);//申请一个临时图像
            Blit(cmd,passSrc,passTempleColorTex.Identifier(),passMat,passMatInt);//把源贴图输入到材质对应的pass里处理，并把处理结果的图像存储到临时图像；
            Blit(cmd,passTempleColorTex.Identifier(),passSrc);//然后把临时图像又存到源图像里
            context.ExecuteCommandBuffer(cmd);//执行命令缓冲区的该命令
            CommandBufferPool.Release(cmd);//释放该命令
            cmd.ReleaseTemporaryRT(passTempleColorTex.id);
        }

        // 清理在执行此渲染阶段期间创建的任何已分配资源.
        public override void OnCameraCleanup(CommandBuffer cmd)
        {
        }
    }

    CustomRenderPass myPass;

    /// <inheritdoc/>
    public override void Create()//初始化
    {
        //计算材质球里总的pass数，如果没有则为1
        int passInt = setting.myMat == null ? 1 : setting.myMat.passCount - 1;
        //把设置里的pass的id限制在-1到材质球最大的pass
        setting.matPassIndex = Mathf.Clamp(setting.matPassIndex, -1, passInt);
        //实例化并传参
        myPass = new CustomRenderPass(setting.passEvent,setting.myMat,setting.matPassIndex,name);

        // Configures where the render pass should be injected.
        myPass.renderPassEvent = RenderPassEvent.AfterRenderingOpaques;
    }

    // Here you can inject one or multiple render passes in the renderer.
    // This method is called when setting up the renderer once per-camera.
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        var src = renderer.cameraColorTarget;
        myPass.setup(src);
        renderer.EnqueuePass(myPass);
    }
}