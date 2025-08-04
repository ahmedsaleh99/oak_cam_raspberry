import depthai as dai
import time
import signal
from pathlib import Path
import subprocess
import argparse

def record_video(output_file: Path, duration: int = 60):
    start_time = time.time()
    with dai.Pipeline() as pipeline:
        def signal_handler(sig, frame):
            print("Interrupted, stopping the pipeline")
            pipeline.stop()
        signal.signal(signal.SIGINT, signal_handler)

        cam = pipeline.create(dai.node.Camera).build(dai.CameraBoardSocket.CAM_A)
        videoEncoder = pipeline.create(dai.node.VideoEncoder).build(cam.requestOutput((4032, 2880), dai.ImgFrame.Type.NV12)) #  (3840, 2160) (4032, 3040) (4032, 2880)
        videoEncoder.setNumFramesPool(1)
        videoEncoder.setDefaultProfilePreset(15, dai.VideoEncoderProperties.Profile.H265_MAIN)
        videoEncoder.setQuality(100)
        q = videoEncoder.bitstream.createOutputQueue()
        pipeline.start()
        with open(output_file, 'wb') as video_file:
            print("Recording H.265 video. Press Ctrl+C to stop.")
            while pipeline.isRunning() and (time.time() - start_time) < duration:
                try:
                    q.get().getData().tofile(video_file)
                except Exception:
                    pass
            print(f"Saved to {output_file}")

def convert_to_mp4(input_file: Path):
    mp4_file = input_file.with_suffix('.mp4')
    print(f"Converting to {mp4_file}...")

    ffmpeg_cmd = [
        "ffmpeg",
        "-y",
        "-i", str(input_file),
        "-c", "copy",
        str(mp4_file)
    ]

    try:
        subprocess.run(ffmpeg_cmd, check=True)
        print(f"Conversion complete: {mp4_file}")
    except subprocess.CalledProcessError as e:
        print(f"FFmpeg conversion failed: {e}")

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="Record RGB video from OAK camera and convert to MP4.")
    parser.add_argument("--output", type=str, default="record", help="Output file name (default: record)")
    parser.add_argument("--duration", type=int, default=60, help="Recording duration in seconds (default: 60)")
    args = parser.parse_args()
    output_file = Path(args.output).with_suffix('.h265')
    record_video(output_file, duration=args.duration)
    convert_to_mp4(output_file)